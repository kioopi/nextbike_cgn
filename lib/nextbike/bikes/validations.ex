defmodule NBC.Bikes.Bike.Validations.HasMoved do
  use Ash.Resource.Validation

  alias Ash.Changeset
  alias NBC.Bikes.Bike

  @impl true
  def init(_opts) do
    {:ok, []}
  end

  @impl true
  def validate(changeset, _opts, _context) do
    number = Changeset.get_attribute(changeset, :number)
    lat = Changeset.get_attribute(changeset, :lat)
    lng = Changeset.get_attribute(changeset, :lng)

    case has_moved?(Bike.current(number), lat, lng) do
      true -> :ok
      false -> {:error, message: "Bike has not moved"}
    end
  end

  # probably not needed
  #  defp has_moved?({:error, %Ash.Error.Invalid{errors: [%Ash.Error.Query.NotFound{}]}}, _, _),
  #    do: true

  defp has_moved?({:ok, %Bike{lat: lat, lng: lng}}, new_lat, new_lng)
       when new_lat == lat and new_lng == lng,
       do: false

  defp has_moved?(_, _, _), do: true
end
