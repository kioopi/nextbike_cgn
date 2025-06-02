defmodule NBCWeb.BikeLive.Show do
  use NBCWeb, :live_view
  alias NBC.Bikes

  @impl true
  def mount(%{"number" => number}, _session, socket) do
    bike_number = String.to_integer(number)
    
    case Bikes.bike_history(bike_number) do
      {:ok, [_ | _] = history} ->
        current_bike = List.first(history)
        
        {:ok,
         assign(socket,
           bike_number: bike_number,
           current_bike: current_bike,
           history: history,
           loading: false,
           error: nil
         )}
      
      {:ok, []} ->
        {:ok,
         assign(socket,
           bike_number: bike_number,
           current_bike: nil,
           history: [],
           loading: false,
           error: "Bike not found"
         )}
      
      {:error, _} ->
        {:ok,
         assign(socket,
           bike_number: bike_number,
           current_bike: nil,
           history: [],
           loading: false,
           error: "Bike not found"
         )}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"number" => number}) do
    socket
    |> assign(:page_title, "Bike #{number}")
  end

  defp format_datetime(datetime) do
    datetime
    |> DateTime.to_naive()
    |> NaiveDateTime.to_string()
    |> String.slice(0, 16)
    |> String.replace("T", " ")
  end

  defp format_location(bike) do
    case bike.place_name do
      nil -> "Unknown location"
      name -> 
        if name == "BIKE #{bike.number}" do
          "#{bike.lat}, #{bike.lng}"
        else
          name
        end
    end
  end
end