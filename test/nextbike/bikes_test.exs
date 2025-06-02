defmodule NBC.BikesTest do
  use NBC.DataCase

  alias NBC.Bikes
  import NBC.Generator, only: [bike: 1, bike: 0, generate: 1]

  describe "create_bike" do
    test "creates a bike with valid attributes" do
      # Generate bike attributes using the generator
      bike_params = %{
        number: 1,
        lat: Faker.Address.latitude(),
        lng: Faker.Address.longitude()
      }

      # Create the bike
      assert {:ok, bike} = Bikes.create_bike(bike_params)

      # Verify the bike has correct attributes
      assert bike.number == bike_params.number
      assert bike.lat == bike_params.lat
      assert bike.lng == bike_params.lng
    end

    test "fails to create a bike if it has not moved" do
      # Generate a bike with specific number
      number = 4
      lat = Faker.Address.latitude()
      lng = Faker.Address.longitude()

      generate(bike(number: number, lat: lat, lng: lng))

      # Try to create the same bike again with the same coordinates
      {:error, ash_error} = Bikes.create_bike(%{number: number, lat: lat, lng: lng})

      # Should fail with the appropriate error
      assert %Ash.Error.Invalid{errors: errors} = ash_error

      assert Enum.any?(errors, fn error ->
               error.message == "Bike has not moved"
             end)
    end

    test "successfully creates a bike if it has moved" do
      # Generate a bike with specific number
      number = 7
      lat = Faker.Address.latitude()
      lng = Faker.Address.longitude()

      # Create first bike
      first_bike = generate(bike(number: number, lat: lat, lng: lng))

      # Create the same bike with new coordinates
      {:ok, second_bike} =
        Bikes.create_bike(%{number: number, lat: lat + 0.001, lng: lng + 0.001})

      # Verify both bikes exist but are different
      assert first_bike.id != second_bike.id
      assert first_bike.number == second_bike.number
      assert first_bike.lat != second_bike.lat
      assert first_bike.lng != second_bike.lng
    end

    test "creates a bike if it has the same coordinates as a previous but not the last bike" do
      # Generate a number for our test bike
      number = 42
      lat_a = Faker.Address.latitude()
      lng_a = Faker.Address.longitude()

      # Create first bike at position A
      first_bike = generate(bike(number: number, lat: lat_a, lng: lng_a))

      # Create second bike at position B
      second_bike = generate(bike(number: number, lat: lat_a + 0.001, lng: lng_a + 0.001))

      # Now create third bike at position A again - this should work
      # since it's different from the most recent position (B)
      {:ok, created_bike} = Bikes.create_bike(%{number: number, lat: lat_a, lng: lng_a})

      # Verify we have three distinct bikes
      assert first_bike.id != second_bike.id
      assert second_bike.id != created_bike.id
      assert first_bike.id != created_bike.id

      # Verify first and third bikes have the same coordinates
      assert first_bike.lat == created_bike.lat
      assert first_bike.lng == created_bike.lng
    end
  end

  describe "list_bikes" do
    test "returns list of bikes" do
      # Create bikes using the generator
      generate(bike(number: 1))
      generate(bike(number: 2))
      generate(bike(number: 3))

      # Get all bikes
      {:ok, bikes} = Bikes.list_bikes()

      # Verify we have bikes
      assert length(bikes) > 0

      # Verify all bikes are in the list
      assert [3, 2, 1] = Enum.map(bikes, & &1.number)
    end

    test "returns only the most recent bike for each number" do
      # Create first set of bikes with the same number
      number = 1

      # Create older bike
      older_bike = generate(bike(number: number))

      # Wait briefly to ensure different timestamps
      Process.sleep(1)

      # Create newer bike with same number
      newer_bike = generate(bike(number: number))

      # Get all bikes
      {:ok, bikes} = Bikes.list_bikes()

      # Verify we only get one bike with this number
      assert length(bikes) == 1

      # Verify it's the newest one
      [returned_bike] = bikes
      assert returned_bike.id == newer_bike.id
      refute returned_bike.id == older_bike.id

      # Create multiple bikes with different numbers to verify distinct works properly
      bike1 = generate(bike())
      bike2 = generate(bike())

      # Create duplicates with same numbers but newer timestamps
      Process.sleep(1)
      newer_bike1 = generate(bike(number: bike1.number))
      newer_bike2 = generate(bike(number: bike2.number))

      # Get updated list
      {:ok, updated_bikes} = Bikes.list_bikes()

      # Get the bikes with our test numbers
      returned_bike1 = Enum.find(updated_bikes, fn b -> b.number == bike1.number end)
      returned_bike2 = Enum.find(updated_bikes, fn b -> b.number == bike2.number end)

      # Verify we got the newer versions
      assert returned_bike1.id == newer_bike1.id
      assert returned_bike2.id == newer_bike2.id
    end
  end
end
