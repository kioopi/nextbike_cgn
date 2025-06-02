defmodule NBCWeb.Components.Bike.CurrentLocation do
  @moduledoc """
  Current location component displaying bike's current position and coordinates.
  """
  use Phoenix.Component

  @doc """
  Renders a current location card with location name and coordinates.

  ## Examples

      <.current_location bike={bike} format_location={&format_location/1} />

  """
  attr :bike, :map, required: true, doc: "Bike data with lat, lng, and place_name"
  attr :format_location, :any, required: true, doc: "Function to format location"
  attr :class, :string, default: "", doc: "Additional CSS classes"

  def current_location(assigns) do
    ~H"""
    <div class={["card bg-base-100 shadow-lg mb-6", @class]}>
      <div class="card-body">
        <h2 class="card-title text-xl mb-4">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-accent" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
          </svg>
          Current Location
        </h2>
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div class="stat bg-base-200 rounded-lg">
            <div class="stat-title">Location</div>
            <div class="stat-value text-lg"><%= @format_location.(@bike) %></div>
          </div>
          
          <div class="stat bg-base-200 rounded-lg">
            <div class="stat-title">Coordinates</div>
            <div class="stat-value text-lg">
              <%= Float.round(@bike.lat, 6) %>, <%= Float.round(@bike.lng, 6) %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end