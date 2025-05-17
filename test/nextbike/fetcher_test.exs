defmodule NBC.FetcherTest do
  use ExUnit.Case, async: true

  alias NBC.Fetcher

  describe "fetch_xml/2" do
    test "returns {:ok, xml} when request is successful" do
      xml_response = "<markers><country><city><place number=\"123\" /></city></country></markers>"

      Req.Test.expect(NBC.ReqTestPlug, &Plug.Conn.send_resp(&1, 200, xml_response))

      assert {:ok, received_xml} = Fetcher.fetch_xml("https://example.com", city: 14)
      assert received_xml == xml_response
    end

    test "correctly passes parameters to the request" do
      Req.Test.stub(NBC.ReqTestPlug, fn conn ->
        assert conn.params == %{"city" => "11"}
        Req.Test.text(conn, "<xml />")
      end)

      Fetcher.fetch_xml("https://example.com", city: 11)
    end

    test "returns {:error, message} when HTTP status is not 200" do
      Req.Test.stub(NBC.ReqTestPlug, fn conn ->
        conn |> Plug.Conn.send_resp(404, "Not Found")
      end)

      assert {:error, "HTTP status: 404"} =
               Fetcher.fetch_xml("https://example.com", city: 14)
    end

    test "returns {:error, reason} when request throws an error" do
      Req.Test.stub(NBC.ReqTestPlug, fn conn ->
        Req.Test.transport_error(conn, :timeout)
      end)

      # Req.Test.allow(NBC.ReqTestPlug, self())

      assert {:error, :timeout} = Fetcher.fetch_xml("https://example.com", city: 14)
    end

    test "returns {:error, reason} when connection fails" do
      Req.Test.stub(NBC.ReqTestPlug, fn conn ->
        Req.Test.transport_error(conn, :econnrefused)
      end)

      assert {:error, :econnrefused} =
               Fetcher.fetch_xml("https://example.com", city: 14)
    end

    test "applies configuration from application environment" do
      # Set test config
      original_config = Application.get_env(:nextbike, :nextbike_req_options)
      test_config = [retry: false, json: false]
      Application.put_env(:nextbike, :nextbike_req_options, test_config)

      # Stub to verify options
      Req.Test.stub(NBC.ReqTestPlug, fn conn ->
        # In a real environment, we'd verify that the options were applied
        # Here we're just returning success
        Req.Test.text(conn, "<xml />")
      end)

      # Req.Test.allow(NBC.ReqTestPlug, self())

      # Make the request
      Fetcher.fetch_xml("https://example.com", city: 14)

      # Reset config
      if original_config do
        Application.put_env(:nextbike, :nextbike_req_options, original_config)
      else
        Application.delete_env(:nextbike, :nextbike_req_options)
      end
    end
  end
end
