defmodule NBCWeb.Components.Bike.Header do
  @moduledoc """
  Bike header component displaying bike number, last seen time, and status.
  """
  use Phoenix.Component

  @doc """
  Renders a bike header card with number, last seen time, and status badge.

  ## Examples

      <.bike_header bike_number={12345} current_bike={bike} history_count={5} />
      <.bike_header bike_number={12345} current_bike={nil} history_count={0} />

  """
  attr :bike_number, :integer, required: true, doc: "The bike number to display"
  attr :current_bike, :map, default: nil, doc: "Current bike data with inserted_at timestamp"
  attr :history_count, :integer, default: 0, doc: "Number of history records"
  attr :format_datetime, :any, required: true, doc: "Function to format datetime"
  attr :class, :string, default: "", doc: "Additional CSS classes"

  def bike_header(assigns) do
    ~H"""
    <div class={["card bg-base-100 shadow-lg mb-6", @class]}>
      <div class="card-body">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="card-title text-3xl">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 text-primary" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16V6a1 1 0 00-1-1H4a1 1 0 00-1 1v10a1 1 0 001 1h1m8-1a1 1 0 01-1 1H9m4-1V8a1 1 0 011-1h2.586a1 1 0 01.707.293l2.414 2.414a1 1 0 01.293.707V16a1 1 0 01-1 1h-1m-6-1a1 1 0 001 1h1M5 17a2 2 0 104 0m-4 0a2 2 0 114 0m6 0a2 2 0 104 0m-4 0a2 2 0 114 0" />
              </svg>
              Bike <%= @bike_number %>
            </h1>
            <%= if @current_bike do %>
              <p class="text-base-content/70">
                Last seen: <%= @format_datetime.(@current_bike.inserted_at) %>
              </p>
            <% end %>
          </div>
          
          <%= if @current_bike do %>
            <div class="badge badge-primary badge-lg">
              <%= if @history_count == 1 do %>
                First record
              <% else %>
                Active
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end