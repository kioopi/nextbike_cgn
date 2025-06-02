defmodule NBCWeb.Components.Bike.ErrorState do
  @moduledoc """
  Error state component for displaying bike not found and other error messages.
  """
  use Phoenix.Component

  @doc """
  Renders an error alert with a customizable message and icon.

  ## Examples

      <.error_state message="Bike not found" />
      <.error_state message="Network error occurred" />

  """
  attr :message, :string, required: true, doc: "Error message to display"
  attr :class, :string, default: "", doc: "Additional CSS classes"

  def error_state(assigns) do
    ~H"""
    <div class={["alert alert-error mb-6", @class]}>
      <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
      <span><%= @message %></span>
    </div>
    """
  end
end