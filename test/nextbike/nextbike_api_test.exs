defmodule NBC.NextbikeAPITest do
  use ExUnit.Case, async: true

  doctest NBC.NextbikeAPI

  alias NBC.NextbikeAPI
  alias NBC.NextbikeAPI.{Bike, Place}

  describe "xml_to_struct/1" do
    test "parses a single place with a single valid bike" do
      xml_content = ~S"""
      <place lat="50.938831" lng="6.90627" name="KVB Hauptverwaltung" number="50712" place_type="0">
        <bike number="221130" bike_type="196" active="1" state="ok" />
      </place>
      """

      [result] = NextbikeAPI.xml_to_struct(xml_content)

      assert result.lat == 50.938831
      assert result.lng == 6.90627
      assert result.name == "KVB Hauptverwaltung"
      assert result.number == 50712
      assert result.place_type == 0

      assert length(result.bikes) == 1

      [bike] = result.bikes
      assert bike.number == 221_130
    end

    test "parses places that lack required fields" do
      # This place is missing :lat and :lng, which are required by the changeset
      # but we are testing the XML parsing here
      # so we expect the place to be parsed without errors
      # the validation takes place in the changeset
      xml_content = ~S"""
      <place name="Invalid Station" number="999" place_type="0">
        <bike number="4500" bike_type="196" active="1" state="ok" />
      </place>
      """

      [result] = NextbikeAPI.xml_to_struct(xml_content)
      assert result.lat == nil
    end
  end

  describe "parse_place_xml/1" do
    test "parses a single place with a single valid bike" do
      xml_content = ~S"""
      <place lat="50.938831" lng="6.90627" name="KVB Hauptverwaltung" number="50712" place_type="0">
        <bike number="221130" bike_type="196" active="1" state="ok" />
      </place>
      """

      [place] = NextbikeAPI.parse_place_xml(xml_content)
      assert %Place{} = place

      assert place.lat == 50.938831
      assert place.lng == 6.90627
      assert place.name == "KVB Hauptverwaltung"
      assert place.number == 50712
      assert place.place_type == 0

      assert length(place.bikes) == 1

      [bike] = place.bikes
      assert %Bike{} = bike
      assert bike.number == 221_130
      # assert bike.bike_type == "196"
      # assert bike.active == true
      # assert bike.state == "ok"
    end

    test "parses a place with multiple bikes; filters out invalid bikes" do
      xml_content = ~S"""
      <place lat="51.12345" lng="7.12345" name="Multiple Bikes Station" number="60001" place_type="1">
        <bike number="1001" bike_type="196" active="1" state="ok" />
        <bike bike_type="unknown" active="1" state="ok" />
        <bike number="1003" bike_type="196" active="1" />
      </place>
      """

      [place] = NextbikeAPI.parse_place_xml(xml_content)
      assert %Place{} = place
      assert place.name == "Multiple Bikes Station"

      # The second bike is invalid (missing 'number'), so it should be filtered out.
      # We expect 2 bikes in total: #1001 and #1003
      assert length(place.bikes) == 2
    end

    test "parses multiple places, each with bikes" do
      xml_content = ~S"""
      <places>
        <place lat="10.0" lng="20.0" name="Station A" number="111" place_type="0">
          <bike number="9001" bike_type="196" active="1" state="ok" />
        </place>
        <place lat="30.0" lng="40.0" name="Station B" number="222" place_type="1">
          <bike number="9002" bike_type="196" active="1" state="ok" />
          <bike number="9003" bike_type="196" active="1" state="ok" />
        </place>
      </places>
      """

      places = NextbikeAPI.parse_place_xml(xml_content)
      assert length(places) == 2

      [place_a, place_b] = places
      assert place_a.name == "Station A"
      assert place_b.name == "Station B"

      assert length(place_a.bikes) == 1
      assert length(place_b.bikes) == 2
    end

    test "filters out places that lack required fields" do
      # This place is missing :lat and :lng, which are required by the changeset
      xml_content = ~S"""
      <place name="Invalid Station" number="999" place_type="0">
        <bike number="4500" bike_type="196" active="1" state="ok" />
      </place>
      """

      result = NextbikeAPI.parse_place_xml(xml_content)
      # The result should be an empty list because the place is invalid
      assert result == []
    end

    test "handles empty or malformed XML" do
      xml_content = ""
      result = NextbikeAPI.parse_place_xml(xml_content)
      assert result == []

      # Could test malformed XML if SweetXml doesn’t raise an error:
      # But usually SweetXml will raise a parsing error on truly malformed content
      # so you may want to handle that at a higher level.
    end
  end

  describe "parse_place_attrs/1" do
    test "returns nil if place data is invalid" do
      place_attrs = %{
        # required
        lat: nil,
        lng: 7.022054,
        name: "Incomplete Station"
      }

      assert NextbikeAPI.parse_place_attrs(place_attrs) == nil
    end

    test "returns a Place struct if data is valid" do
      place_attrs = %{
        lat: 50.980271,
        lng: 7.022054,
        name: "Test Station",
        number: 123,
        place_type: "16",
        bikes: []
      }

      assert %Place{lat: 50.980271, lng: 7.022054, name: "Test Station"} =
               NextbikeAPI.parse_place_attrs(place_attrs)
    end
  end

  describe "validate_bike_attrs/1" do
    test "returns nil if required fields are missing" do
      bike_attrs = %{bike_type: "196", active: true, state: "ok"}
      assert NextbikeAPI.validate_bike_attrs(bike_attrs) == nil
    end

    test "returns a map if data is valid" do
      bike_attrs = %{number: 12345, bike_type: "196", active: true, state: "ok"}

      assert %{number: 12345, bike_type: "196", active: true, state: "ok"} =
               NextbikeAPI.validate_bike_attrs(bike_attrs)
    end
  end
end
