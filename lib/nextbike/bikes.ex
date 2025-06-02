defmodule NBC.Bikes do
  use Ash.Domain,
    otp_app: :nextbike

  resources do
    resource NBC.Bikes.Bike do
      define :list_bikes, action: :list_current
      define :create_bike, action: :create_if_moved
      define :create_bikes_from_api, action: :create_from_api
      define :bike_history, action: :history, args: [:number]
    end
  end
end
