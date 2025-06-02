defmodule NBCWeb.Components.Bike.EmptyData do
  @moduledoc """
  Empty data component for when bike exists but has no data available.
  """
  use Phoenix.Component

  @doc """
  Renders an empty data state card with a message for when no bike data is available.

  ## Examples

      <.empty_data bike_number={12345} />
      <.empty_data bike_number={12345} message="Custom message" />

  """
  attr :bike_number, :integer, required: true, doc: "The bike number to display"
  attr :message, :string, default: nil, doc: "Custom message to display"
  attr :class, :string, default: "", doc: "Additional CSS classes"

  def empty_data(assigns) do
    assigns = assign_new(assigns, :message, fn ->
      "No location data found for bike #{assigns.bike_number}."
    end)

    ~H"""
    <div class={["card bg-base-100 shadow-lg", @class]}>
      <div class="card-body text-center">
        <div class="text-base-content/50">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-16 w-16 mx-auto mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.172 16.172a4 4 0 015.656 0M9 12h6m-6-4h6m2 5.291A7.962 7.962 0 0112 15c-2.34 0-4.47.943-6.017 2.472M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
          </svg>
          <h3 class="text-lg font-semibold mb-2">No Data Available</h3>
          <p><%= @message %></p>
        </div>
      </div>
    </div>
    """
  end
end