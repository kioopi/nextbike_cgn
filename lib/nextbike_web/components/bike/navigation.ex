defmodule NBCWeb.Components.Bike.Navigation do
  @moduledoc """
  Navigation component for back navigation and other navigation actions.
  """
  use Phoenix.Component

  @doc """
  Renders a navigation section with a back button and optional additional actions.

  ## Examples

      <.navigation back_url={~p"/"} back_text="Back to All Bikes" />
      <.navigation back_url={~p"/dashboard"} back_text="Back to Dashboard" />

  """
  attr :back_url, :string, required: true, doc: "URL to navigate back to"
  attr :back_text, :string, default: "Back", doc: "Text for the back button"
  attr :class, :string, default: "", doc: "Additional CSS classes"

  slot :actions, doc: "Additional navigation actions"

  def navigation(assigns) do
    ~H"""
    <div class={["mt-6 flex items-center justify-between", @class]}>
      <.link navigate={@back_url} class="btn btn-outline">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
        </svg>
        <%= @back_text %>
      </.link>
      
      <%= if @actions != [] do %>
        <div class="flex gap-2">
          <%= render_slot(@actions) %>
        </div>
      <% end %>
    </div>
    """
  end
end