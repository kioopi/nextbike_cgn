defmodule NBCWeb.Components.BikeHistoryMapComponent do
  use NBCWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> prepare_history_map()

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="card bg-base-100 shadow-lg">
      <div class="card-body">
        <h2 class="card-title text-xl mb-4">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-6 w-6 text-primary"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-1.447-.894L15 4m0 13V4m-6 3l6-3"
            />
          </svg>
          Movement Path (Today)
          <div class="badge badge-primary">{length(@today_history)} locations</div>
        </h2>

        <%= if length(@today_history) > 1 do %>
          <div
            id="bike-history-map"
            phx-hook="BikeHistoryMap"
            phx-update="ignore"
            style="width: 100%; height: 400px; border-radius: 0.5rem;"
            data-map-spec={Jason.encode!(@map_spec)}
          >
          </div>
          <div class="mt-4 p-3 bg-base-200 rounded-lg">
            <h3 class="text-sm font-medium mb-2">Legend</h3>
            <div class="flex flex-wrap gap-4 text-xs">
              <div class="flex items-center gap-2">
                <div class="w-4 h-1 bg-primary rounded"></div>
                <span>Movement path</span>
              </div>
              <div class="flex items-center gap-2">
                <div class="w-3 h-3 bg-success rounded-full border-2 border-white"></div>
                <span>Start point</span>
              </div>
              <div class="flex items-center gap-2">
                <div class="w-3 h-3 bg-error rounded-full border-2 border-white"></div>
                <span>End point</span>
              </div>
            </div>
          </div>
        <% else %>
          <div class="text-center py-8">
            <div class="text-base-content/50">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="h-16 w-16 mx-auto mb-4"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-1.447-.894L15 4m0 13V4m-6 3l6-3"
                />
              </svg>
              <p>Not enough location data to show movement path.</p>
              <p class="text-sm">At least 2 locations are needed.</p>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp prepare_history_map(socket) do
    history = socket.assigns.history || []

    # Filter to today's history only
    today = Date.utc_today()

    today_history =
      Enum.filter(history, fn record ->
        record.inserted_at
        |> DateTime.to_date()
        |> Date.compare(today) == :eq
      end)

    socket = assign(socket, today_history: today_history)

    if length(today_history) > 1 do
      # Sort by time to create proper line sequence
      sorted_history = Enum.sort_by(today_history, & &1.inserted_at, DateTime)

      # Create coordinates for the line (note: [lng, lat] format for GeoJSON)
      coordinates =
        Enum.map(sorted_history, fn record ->
          [record.lng, record.lat]
        end)

      # Create GeoJSON for the route line
      route_geojson = %{
        type: "Feature",
        properties: %{},
        geometry: %{
          type: "LineString",
          coordinates: coordinates
        }
      }

      # Create GeoJSON features for start and end points
      start_point = List.first(sorted_history)
      end_point = List.last(sorted_history)

      points_features = [
        %{
          type: "Feature",
          geometry: %{
            type: "Point",
            coordinates: [start_point.lng, start_point.lat]
          },
          properties: %{
            type: "start",
            time: Calendar.strftime(start_point.inserted_at, "%H:%M")
          }
        },
        %{
          type: "Feature",
          geometry: %{
            type: "Point",
            coordinates: [end_point.lng, end_point.lat]
          },
          properties: %{
            type: "end",
            time: Calendar.strftime(end_point.inserted_at, "%H:%M")
          }
        }
      ]

      points_geojson = %{
        type: "FeatureCollection",
        features: points_features
      }

      # Create the map
      map =
        MapLibre.new(
          style: :street,
          center: calculate_center(coordinates),
          zoom: calculate_zoom(coordinates)
        )
        |> MapLibre.add_source("route-source",
          type: :geojson,
          data: route_geojson
        )
        |> MapLibre.add_source("points-source",
          type: :geojson,
          data: points_geojson
        )
        |> MapLibre.add_layer(
          id: "route-line",
          type: :line,
          source: "route-source",
          layout: %{
            "line-join" => "round",
            "line-cap" => "round"
          },
          paint: %{
            "line-color" => "#570df8",
            "line-width" => 4,
            "line-opacity" => 0.8
          }
        )
        |> MapLibre.add_layer(
          id: "start-point",
          type: :circle,
          source: "points-source",
          filter: ["==", ["get", "type"], "start"],
          paint: %{
            "circle-radius" => 8,
            "circle-color" => "#00d200",
            "circle-stroke-width" => 3,
            "circle-stroke-color" => "#ffffff",
            "circle-opacity" => 0.9
          }
        )
        |> MapLibre.add_layer(
          id: "end-point",
          type: :circle,
          source: "points-source",
          filter: ["==", ["get", "type"], "end"],
          paint: %{
            "circle-radius" => 8,
            "circle-color" => "#ff5722",
            "circle-stroke-width" => 3,
            "circle-stroke-color" => "#ffffff",
            "circle-opacity" => 0.9
          }
        )
        |> MapLibre.add_layer(
          id: "point-labels",
          type: :symbol,
          source: "points-source",
          layout: %{
            "text-field" => ["get", "time"],
            "text-font" => ["Open Sans Regular"],
            "text-offset" => [0, 1.8],
            "text-anchor" => "top",
            "text-size" => 12
          },
          paint: %{
            "text-color" => "#000000",
            "text-halo-color" => "#ffffff",
            "text-halo-width" => 1
          }
        )

      assign(socket, map_spec: MapLibre.to_spec(map))
    else
      assign(socket, map_spec: nil)
    end
  end

  defp calculate_center(coordinates) when length(coordinates) == 0, do: [6.9603, 50.9375]

  defp calculate_center(coordinates) do
    count = length(coordinates)

    {total_lng, total_lat} =
      Enum.reduce(coordinates, {0, 0}, fn [lng, lat], {lng_sum, lat_sum} ->
        {lng_sum + lng, lat_sum + lat}
      end)

    [total_lng / count, total_lat / count]
  end

  defp calculate_zoom(coordinates) when length(coordinates) <= 1, do: 15

  defp calculate_zoom(coordinates) do
    # Calculate bounding box
    lngs = Enum.map(coordinates, fn [lng, _lat] -> lng end)
    lats = Enum.map(coordinates, fn [_lng, lat] -> lat end)

    lng_diff = Enum.max(lngs) - Enum.min(lngs)
    lat_diff = Enum.max(lats) - Enum.min(lats)

    max_diff = max(lng_diff, lat_diff)

    cond do
      max_diff > 0.1 -> 10
      max_diff > 0.05 -> 12
      max_diff > 0.01 -> 14
      true -> 16
    end
  end
end
