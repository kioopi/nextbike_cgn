defmodule NBCWeb.Components.Bike.LocationHistory do
  @moduledoc """
  Location history component displaying a table of bike movement history.
  """
  use Phoenix.Component

  @doc """
  Renders a location history card with a table of bike movements.

  ## Examples

      <.location_history history={history} format_datetime={&format_datetime/1} format_location={&format_location/1} />
      <.location_history history={[]} format_datetime={&format_datetime/1} format_location={&format_location/1} />

  """
  attr :history, :list, required: true, doc: "List of bike history records"
  attr :format_datetime, :any, required: true, doc: "Function to format datetime"
  attr :format_location, :any, required: true, doc: "Function to format location"
  attr :class, :string, default: "", doc: "Additional CSS classes"

  def location_history(assigns) do
    ~H"""
    <div class={["card bg-base-100 shadow-lg", @class]}>
      <div class="card-body">
        <h2 class="card-title text-xl mb-4">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-secondary" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          Location History
          <div class="badge badge-neutral"><%= length(@history) %> records</div>
        </h2>
        
        <%= if length(@history) > 0 do %>
          <div class="overflow-x-auto">
            <table class="table table-zebra">
              <thead>
                <tr>
                  <th>Date & Time</th>
                  <th>Location</th>
                  <th>Coordinates</th>
                </tr>
              </thead>
              <tbody>
                <%= for {bike, index} <- Enum.with_index(@history) do %>
                  <tr class={if index == 0, do: "bg-primary/10"}>
                    <td>
                      <div class="flex items-center gap-2">
                        <%= if index == 0 do %>
                          <div class="badge badge-primary badge-sm">Latest</div>
                        <% end %>
                        <span class="font-mono text-sm">
                          <%= @format_datetime.(bike.inserted_at) %>
                        </span>
                      </div>
                    </td>
                    <td>
                      <div class="max-w-xs truncate" title={@format_location.(bike)}>
                        <%= @format_location.(bike) %>
                      </div>
                    </td>
                    <td>
                      <div class="font-mono text-sm">
                        <%= Float.round(bike.lat, 6) %>, <%= Float.round(bike.lng, 6) %>
                      </div>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        <% else %>
          <.empty_state />
        <% end %>
      </div>
    </div>
    """
  end

  defp empty_state(assigns) do
    ~H"""
    <div class="text-center py-8">
      <div class="text-base-content/50">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-16 w-16 mx-auto mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.172 16.172a4 4 0 015.656 0M9 12h6m-6-4h6m2 5.291A7.962 7.962 0 0112 15c-2.34 0-4.47.943-6.017 2.472M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
        </svg>
        <p>No location history available for this bike.</p>
      </div>
    </div>
    """
  end
end