defmodule NBCWeb.Components.BikeHistoryMapComponentTest do
  use NBCWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias NBCWeb.Components.BikeHistoryMapComponent

  describe "BikeHistoryMapComponent" do
    test "renders empty state when history has less than 2 records" do
      history = [
        %{
          inserted_at: DateTime.utc_now(),
          place_name: "Station A",
          lat: 50.9375,
          lng: 6.9603
        }
      ]

      html = render_component(BikeHistoryMapComponent, %{
        id: "test-map",
        history: history
      })

      assert html =~ "Movement Path (Today)"
      assert html =~ "Not enough location data to show movement path"
      assert html =~ "At least 2 locations are needed"
    end

    test "renders map when history has 2 or more records from today" do
      now = DateTime.utc_now()
      
      history = [
        %{
          inserted_at: DateTime.add(now, -3600, :second),
          place_name: "Station A",
          lat: 50.9375,
          lng: 6.9603
        },
        %{
          inserted_at: now,
          place_name: "Station B",
          lat: 50.9380,
          lng: 6.9610
        }
      ]

      html = render_component(BikeHistoryMapComponent, %{
        id: "test-map",
        history: history
      })

      assert html =~ "Movement Path (Today)"
      assert html =~ "2 locations"
      assert html =~ "id=\"bike-history-map\""
      assert html =~ "Legend"
      assert html =~ "phx-hook=\"BikeHistoryMap\""
      assert html =~ "Legend"
      assert html =~ "Movement path"
      assert html =~ "Start point"
      assert html =~ "End point"
    end

    test "filters out records that are not from today" do
      now = DateTime.utc_now()
      yesterday = DateTime.add(now, -1, :day)
      
      history = [
        %{
          inserted_at: yesterday,
          place_name: "Yesterday Station",
          lat: 50.9370,
          lng: 6.9600
        },
        %{
          inserted_at: DateTime.add(now, -3600, :second),
          place_name: "Today Station A",
          lat: 50.9375,
          lng: 6.9603
        },
        %{
          inserted_at: now,
          place_name: "Today Station B",
          lat: 50.9380,
          lng: 6.9610
        }
      ]

      html = render_component(BikeHistoryMapComponent, %{
        id: "test-map",
        history: history
      })

      assert html =~ "Movement Path (Today)"
      assert html =~ "2 locations"
      assert html =~ "id=\"bike-history-map\""
    end

    test "renders empty state when no today records exist" do
      yesterday = DateTime.add(DateTime.utc_now(), -1, :day)
      
      history = [
        %{
          inserted_at: yesterday,
          place_name: "Yesterday Station",
          lat: 50.9370,
          lng: 6.9600
        }
      ]

      html = render_component(BikeHistoryMapComponent, %{
        id: "test-map",
        history: history
      })

      assert html =~ "Movement Path (Today)"
      assert html =~ "0 locations"
      assert html =~ "Not enough location data to show movement path"
    end
  end
end