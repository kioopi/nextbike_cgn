defmodule NBC.Generator do
  use Ash.Generator
  alias NBC.Bikes.Bike

  def bike(opts \\ []) do
    changeset_generator(
      Bike,
      :create,
      defaults: [
        lat: StreamData.repeatedly(fn -> Faker.Address.latitude() end),
        lng: StreamData.repeatedly(fn -> Faker.Address.longitude() end),
        number: StreamData.repeatedly(fn -> Faker.random_between(1, 999_999) end),
        place_name: "",
        place_number: ""
      ],
      overrides: opts
    )
  end
end
