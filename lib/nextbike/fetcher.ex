defmodule NBC.Fetcher do
  @moduledoc """
  A module to fetch data from a given URL and parse it.
  """
  require Logger

  @doc """
  Fetches XML data from the given URL and parses it.

  ## Parameters
    - `url`: The URL to fetch data from.
    - `params`: Optional parameters to include in the request.

  ## Returns
    - `{:ok, xml}` on success.
    - `{:error, reason}` on failure.
  """
  def fetch_xml(url, params \\ []) do
    req = Req.new(url: url, params: params)

    options = Application.get_env(:nextbike, :nextbike_req_options, [])
    # Fix retry option to be compatible with Req
    options =
      Keyword.update(options, :retry, false, fn
        count when is_integer(count) -> :transient
        other -> other
      end)

    Req.get(req, options)
    |> handle_response()
  end

  # Successful response handling
  defp handle_response({:ok, %Req.Response{status: status} = response}) when status == 200 do
    {:ok, response.body}
  end

  # Error handling
  defp handle_response({:ok, %Req.Response{status: status}}) do
    {:error, "HTTP status: #{status}"}
  end

  defp handle_response({:error, %Req.TransportError{reason: reason}}) do
    {:error, reason}
  end

  defp handle_response(unknown) do
    {:error, "Unknown error: #{inspect(unknown)}"}
  end
end
