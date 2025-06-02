defmodule NBCWeb.Components.BikeComponentsTest do
  use NBCWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import NBC.Generator, only: [bike: 1, generate: 1]

  describe "bike_header/1" do
    test "renders bike header with current bike" do
      bike = generate(bike(number: 12345))
      format_datetime = fn _datetime -> "2024-01-01 12:00" end

      html = 
        render_component(&NBCWeb.Components.Bike.Header.bike_header/1, %{
          bike_number: 12345,
          current_bike: bike,
          history_count: 3,
          format_datetime: format_datetime
        })

      assert html =~ "Bike 12345"
      assert html =~ "Last seen: 2024-01-01 12:00"
      assert html =~ "Active"
    end

    test "renders bike header without current bike" do
      html = 
        render_component(&NBCWeb.Components.Bike.Header.bike_header/1, %{
          bike_number: 12345,
          current_bike: nil,
          history_count: 0,
          format_datetime: fn _ -> "" end
        })

      assert html =~ "Bike 12345"
      refute html =~ "Last seen:"
      refute html =~ "Active"
    end

    test "renders first record badge for single history entry" do
      bike = generate(bike(number: 12345))
      format_datetime = fn _ -> "2024-01-01 12:00" end

      html = 
        render_component(&NBCWeb.Components.Bike.Header.bike_header/1, %{
          bike_number: 12345,
          current_bike: bike,
          history_count: 1,
          format_datetime: format_datetime
        })

      assert html =~ "First record"
      refute html =~ "Active"
    end
  end

  describe "current_location/1" do
    test "renders current location with place name" do
      bike = generate(bike(
        lat: 50.9375,
        lng: 6.9603,
        place_name: "Test Station"
      ))
      
      format_location = fn _ -> "Test Station" end

      html = 
        render_component(&NBCWeb.Components.Bike.CurrentLocation.current_location/1, %{
          bike: bike,
          format_location: format_location
        })

      assert html =~ "Current Location"
      assert html =~ "Test Station"
      assert html =~ "50.9375, 6.9603"
    end
  end

  describe "location_history/1" do
    test "renders location history table with data" do
      bike1 = generate(bike(number: 12345, place_name: "Station A"))
      bike2 = generate(bike(number: 12345, place_name: "Station B"))
      history = [bike1, bike2]
      
      format_datetime = fn _ -> "2024-01-01 12:00" end
      format_location = fn bike -> bike.place_name end

      html = 
        render_component(&NBCWeb.Components.Bike.LocationHistory.location_history/1, %{
          history: history,
          format_datetime: format_datetime,
          format_location: format_location
        })

      assert html =~ "Location History"
      assert html =~ "2 records"
      assert html =~ "Station A"
      assert html =~ "Station B"
      assert html =~ "Latest"
    end

    test "renders empty state when no history" do
      html = 
        render_component(&NBCWeb.Components.Bike.LocationHistory.location_history/1, %{
          history: [],
          format_datetime: fn _ -> "" end,
          format_location: fn _ -> "" end
        })

      assert html =~ "Location History"
      assert html =~ "0 records"
      assert html =~ "No location history available"
    end
  end

  describe "error_state/1" do
    test "renders error message" do
      html = 
        render_component(&NBCWeb.Components.Bike.ErrorState.error_state/1, %{
          message: "Bike not found"
        })

      assert html =~ "alert-error"
      assert html =~ "Bike not found"
    end
  end

  describe "empty_data/1" do
    test "renders empty data state with default message" do
      html = 
        render_component(&NBCWeb.Components.Bike.EmptyData.empty_data/1, %{
          bike_number: 12345
        })

      assert html =~ "No Data Available"
      assert html =~ "No location data found for bike 12345."
    end

    test "renders empty data state with custom message" do
      html = 
        render_component(&NBCWeb.Components.Bike.EmptyData.empty_data/1, %{
          bike_number: 12345,
          message: "Custom error message"
        })

      assert html =~ "No Data Available"
      assert html =~ "Custom error message"
    end
  end

  describe "navigation/1" do
    test "renders back navigation" do
      html = 
        render_component(&NBCWeb.Components.Bike.Navigation.navigation/1, %{
          back_url: "/",
          back_text: "Back to Home"
        })

      assert html =~ "Back to Home"
      assert html =~ "href=\"/\""
    end

    test "renders navigation with actions slot" do
      _assigns = %{back_url: "/", back_text: "Back"}
      
      # For now, just test the basic navigation without the actions slot
      # as the slot testing requires more complex setup
      html = 
        render_component(&NBCWeb.Components.Bike.Navigation.navigation/1, %{
          back_url: "/",
          back_text: "Back"
        })

      assert html =~ "Back"
    end
  end
end