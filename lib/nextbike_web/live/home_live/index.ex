defmodule NBCWeb.HomeLive.Index do
  use NBCWeb, :live_view
  alias NBC.Bikes

  @impl true
  def mount(_params, _session, socket) do
    {:ok, bikes} = Bikes.list_bikes()

    {:ok,
     assign(socket,
       bikes: bikes,
       loading: false
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Nextbike Bikes CGN")
  end
end
