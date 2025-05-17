defmodule NBC.FetchBikesTest do
  use NBC.DataCase

  alias NBC.Bikes

  describe "Getting bikes from API" do
    setup do
      # Read example XML file from test data
      example_xml = File.read!("test/data/nextbike.xml")
      %{example_xml: example_xml}
    end

    test "can create bikes in database from xml", %{example_xml: xml} do
      assert xml != nil
      # there are no bikes in the db
      bikes = Ash.Query.for_read(Bikes.Bike, :read) |> Ash.read!()
      assert length(bikes) == 0

      # Parse the XML and create bikes
      bikes = Enum.take(NBC.NextbikeAPI.parse_bikes_from_xml(xml), 5)

      result =
        Ash.bulk_create(
          bikes,
          Bikes.Bike,
          :create_if_moved,
          rollback_on_error?: false,
          stop_on_error?: false,
          return_errors?: true
        )

      assert result.status == :success

      bikes = Ash.Query.for_read(Bikes.Bike, :read) |> Ash.read!()
      assert length(bikes) > 0
    end

    test "second fetch with unmoved and moved bike", %{example_xml: xml} do
      bikes = Enum.take(NBC.NextbikeAPI.parse_bikes_from_xml(xml), 5)

      # insert all bike
      %Ash.BulkResult{status: :success} =
        Ash.bulk_create(
          bikes,
          Bikes.Bike,
          :create_if_moved,
          rollback_on_error?: false,
          stop_on_error?: false,
          return_errors?: true
        )

      [b_moved, b_unmoved] = Enum.take(bikes, 2)

      b_moved = Map.update(b_moved, :lat, 0.0, &(&1 + 0.01))

      %Ash.BulkResult{status: :partial_success} =
        result =
        Ash.bulk_create(
          [b_moved, b_unmoved],
          Bikes.Bike,
          :create_if_moved,
          rollback_on_error?: false,
          stop_on_error?: false,
          return_errors?: true
        )

      assert result.status == :partial_success
      assert result.error_count == 1
    end
  end
end
