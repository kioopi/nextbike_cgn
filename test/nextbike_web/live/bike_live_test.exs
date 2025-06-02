defmodule NBCWeb.BikeLiveTest do
  use NBCWeb.ConnCase

  import Phoenix.LiveViewTest
  import NBC.Generator, only: [bike: 1, generate: 1]

  describe "Show" do
    test "displays bike information when bike exists", %{conn: conn} do
      # Create test bike using generator
      bike = generate(bike(
        number: 12345,
        lat: 50.9375,
        lng: 6.9603,
        place_name: "Test Station",
        place_number: 1
      ))

      {:ok, _show_live, html} = live(conn, ~p"/bikes/#{bike.number}")

      assert html =~ "Bike #{bike.number}"
      assert html =~ "Test Station"
      assert html =~ "50.9375"
      assert html =~ "6.9603"
      assert html =~ "Current Location"
      assert html =~ "Location History"
    end

    test "displays error when bike does not exist", %{conn: conn} do
      {:ok, _show_live, html} = live(conn, ~p"/bikes/99999")

      assert html =~ "Bike not found"
    end

    test "displays bike history with multiple records", %{conn: conn} do
      bike_number = 54321

      # Create multiple bike records for the same bike number at different times
      _bike1 = generate(bike(
        number: bike_number,
        lat: 50.9375,
        lng: 6.9603,
        place_name: "Station A"
      ))

      # Sleep to ensure different timestamps
      Process.sleep(10)

      _bike2 = generate(bike(
        number: bike_number,
        lat: 50.9400,
        lng: 6.9650,
        place_name: "Station B"
      ))

      {:ok, _show_live, html} = live(conn, ~p"/bikes/#{bike_number}")

      assert html =~ "Bike #{bike_number}"
      assert html =~ "Station A"
      assert html =~ "Station B"
      assert html =~ "2 records"
      assert html =~ "Latest"
    end

    test "formats location correctly for generic bike names", %{conn: conn} do
      bike_number = 98765

      _bike = generate(bike(
        number: bike_number,
        lat: 50.9375,
        lng: 6.9603,
        place_name: "BIKE #{bike_number}"
      ))

      {:ok, _show_live, html} = live(conn, ~p"/bikes/#{bike_number}")

      assert html =~ "50.9375, 6.9603"
    end

    test "handles bike with no place name", %{conn: conn} do
      bike_number = 11111

      _bike = generate(bike(
        number: bike_number,
        lat: 50.9375,
        lng: 6.9603,
        place_name: nil
      ))

      {:ok, _show_live, html} = live(conn, ~p"/bikes/#{bike_number}")

      assert html =~ "Unknown location"
    end

    test "includes back navigation link", %{conn: conn} do
      bike = generate(bike(
        number: 33333,
        lat: 50.9375,
        lng: 6.9603,
        place_name: "Test Station"
      ))

      {:ok, show_live, html} = live(conn, ~p"/bikes/#{bike.number}")

      assert html =~ "Back to All Bikes"
      
      # Test that clicking the link navigates to home
      assert {:error, {:live_redirect, %{to: "/"}}} = 
        show_live
        |> element("a", "Back to All Bikes")
        |> render_click()
    end
  end
end