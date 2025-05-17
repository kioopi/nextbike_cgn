defmodule NBC.NextbikeAPI do
  @moduledoc """
  Context for handling data from the external Nextbike API.
  Provides embedded schemas for decoding/validating XML responses.
  """
  import SweetXml
  require Logger

  alias NBC.NextbikeAPI.{Bike, Place}

  defmodule Bike do
    @moduledoc """
    Embedded schema for a single bike in the external Nextbike API response.
    """

    use Ecto.Schema
    import Ecto.Changeset

    embedded_schema do
      field :number, :integer
      field :bike_type, :integer
      field :active, :boolean
      field :state, :string
    end

    @doc """
    Changeset to cast and validate bike data coming from the API.
    """
    def changeset(bike, attrs) do
      bike
      |> cast(attrs, [
        :number,
        :bike_type,
        :active,
        :state
      ])
      |> validate_required([:number])
    end
  end

  defmodule Place do
    @moduledoc """
    Embedded schema for a single place (station) in the external Nextbike API response.
    """

    use Ecto.Schema
    import Ecto.Changeset

    embedded_schema do
      field :lat, :float
      field :lng, :float
      field :name, :string
      field :number, :integer
      field :place_type, :integer

      # Bikes embedded under <place> ... <bike ... /> ... </place>
      embeds_many :bikes, Bike
    end

    @doc """
    Changeset to cast and validate place (station) data coming from the API.
    """
    def changeset(place, attrs) do
      place
      |> cast(attrs, [
        :lat,
        :lng,
        :name,
        :number,
        :place_type
      ])
      # Cast the nested bikes
      |> cast_embed(:bikes, with: &Bike.changeset/2)
      # For example, require lat, lng, etc.
      |> validate_required([:lat, :lng])
    end
  end

  @doc ~S'''
  Takes a string of XML content and parses it into a list of Place structs.
  Each Place struct contains a list of Bike structs.

  ## Examples
  #  iex> xml_content = """
  #  <place lat="50.938831" lng="6.90627" name="KVB Hauptverwaltung" number="50712" place_type="0">
  #    <bike number="221130" bike_type="196"active="1" state="ok"/>
  #  </place>
  #  """
  #  #  iex> NextbikeAPI.parse_place_xml(xml_content)
  #  [%Place{lat: 50.938831, lng: 6.90627, name: "KVB Hauptverwaltung", number: 50712, place_type: 0, bikes: [%Bike{number: 221130}]}]
  '''
  def parse_place_xml(), do: []
  def parse_place_xml(""), do: []

  def parse_place_xml(xml_content) do
    # TODO: This could be changed to be a stream
    xml_content
    |> xml_to_struct()
    |> Enum.map(&parse_place_attrs/1)
    # Remove any nils for places that didn’t pass validation
    |> Enum.reject(&is_nil/1)
  end

  def parse_bikes_from_xml(xml_content) do
    xml_content
    |> xml_to_struct()
    |> Enum.flat_map(fn place_attrs ->
      # Extract common place data
      place_data = %{
        place_name: place_attrs[:name],
        place_number: place_attrs[:number],
        lat: place_attrs[:lat],
        lng: place_attrs[:lng]
      }

      # Map each bike, combining with place data
      (place_attrs[:bikes] || [])
      |> Enum.map(fn bike_attrs ->
        bike_attrs
        |> Map.merge(place_data)
        |> validate_bike_with_location()
      end)
      |> Enum.reject(&is_nil/1)
    end)
  end

  defp validate_bike_with_location(attrs) do
    bike_cs = Ash.Changeset.for_create(NBC.Bikes.Bike, :create, attrs)

    if bike_cs.valid? do
      {:ok, bike_changeset} = Ash.Changeset.apply_attributes(bike_cs)

      Map.from_struct(bike_changeset)
      |> Map.take([:lat, :lng, :number, :place_name, :place_number])
    else
      Logger.warning("Invalid bike data: #{inspect(bike_cs.errors)}")
      nil
    end
  end

  @doc """
  Takes a string of XML content and parses it into a list of structs.
  Each struct contains the attributes of a place and its bikes.
  All elements are optional because the validation is done later via the embedded schemata/changesets.
  """
  def xml_to_struct(xml_content) do
    xml_content
    # TODO move to a separate function parse_xml that only parses and does not validate
    |> SweetXml.xpath(
      # `~x"//place"` means “all place elements from anywhere in the doc”
      ~x"//place"l,
      lat: ~x"./@lat"fo,
      lng: ~x"./@lng"fo,
      name: ~x"./@name"so,
      number: ~x"./@number"io,
      place_type: ~x"./@place_type"io,
      bikes: [
        # Nested mapping for <bike> children
        ~x"./bike"l,
        number: ~x"./@number"io
        # bike_type: ~x"./@bike_type"s
      ]
    )
  end

  @doc """
  Parse and validate the place attributes. The Place structs contain a list of bike stucts.
  """
  def parse_place_attrs(place_attrs) do
    # parse/validate each bike. Keep only the valid ones.
    valid_bikes =
      (place_attrs[:bikes] || [])
      |> Enum.map(&validate_bike_attrs/1)
      |> Enum.reject(&is_nil/1)

    # Put the valid bikes back into the place map and validate
    updated_place_attrs = Map.put(place_attrs, :bikes, valid_bikes)
    place_cs = Place.changeset(%Place{}, updated_place_attrs)

    # Only return a struct for the place if it’s valid
    if place_cs.valid? do
      Ecto.Changeset.apply_changes(place_cs)
    else
      # Log the error or handle it as needed
      Logger.warning("Invalid place data: #{inspect(place_cs.errors)}")
      nil
    end
  end

  def validate_bike_attrs(bike_attrs) do
    bike_cs = Bike.changeset(%Bike{}, bike_attrs)

    # If the bike is valid, apply_changes to get the struct; otherwise, skip it
    if bike_cs.valid? do
      bike_attrs
    else
      Logger.warning("Invalid bike data: #{inspect(bike_cs.errors)}")
      nil
    end
  end
end
