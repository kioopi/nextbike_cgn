defmodule NBCWeb.Components.BikeMapComponent do
  use NBCWeb, :live_component

  # alias Nextbike.Bikes
  # alias Phoenix.LiveView.JS

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> prepare_map()

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div
        id="bike-map"
        phx-hook="BikeMap"
        phx-update="ignore"
        style="width: 100%; height: 400px; margin-bottom: 20px;"
        data-map-spec={Jason.encode!(@map_spec)}
      >
      </div>
    </div>
    """
  end

  defp prepare_map(socket) do
    bikes = socket.assigns.bikes || []

    # Create a GeoJSON feature collection for bike locations
    features =
      Enum.map(bikes, fn bike ->
        %{
          type: "Feature",
          geometry: %{
            type: "Point",
            coordinates: [bike.lng, bike.lat]
          },
          properties: %{
            id: bike.id,
            number: bike.number,
            place_name: bike.place_name || "",
            place_number: bike.place_number
          }
        }
      end)

    # Create a GeoJSON feature collection
    geojson = %{
      type: "FeatureCollection",
      features: features
    }

    # Create the map with the bikes data
    map =
      MapLibre.new(
        style: :street,
        center: average_center(bikes),
        zoom: 12
      )
      |> MapLibre.add_source("bikes-source",
        type: :geojson,
        data: geojson
      )
      |> MapLibre.add_layer(
        id: "bikes-layer",
        type: :circle,
        source: "bikes-source",
        paint: %{
          "circle-radius": 6,
          "circle-color": "#4287f5",
          "circle-stroke-width": 1,
          "circle-stroke-color": "#ffffff"
        }
      )
      |> MapLibre.add_layer(
        id: "bikes-labels",
        type: :symbol,
        source: "bikes-source",
        layout: %{
          "text-field": ["get", "number"],
          "text-font": ["Open Sans Regular"],
          "text-offset": [0, 1.5],
          "text-anchor": "top"
        },
        paint: %{
          "text-color": "#000000",
          "text-halo-color": "#ffffff",
          "text-halo-width": 1
        }
      )

    assign(socket, map_spec: MapLibre.to_spec(map))
  end

  # Calculate the average center of all bikes for the initial map view
  # Default to Cologne
  defp average_center([]), do: [6.9603, 50.9375]

  defp average_center(bikes) do
    count = length(bikes)

    {total_lng, total_lat} =
      Enum.reduce(bikes, {0, 0}, fn bike, {lng_sum, lat_sum} ->
        {lng_sum + bike.lng, lat_sum + bike.lat}
      end)

    [total_lng / count, total_lat / count]
  end
end
