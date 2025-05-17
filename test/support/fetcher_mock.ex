defmodule NBC.Support.FetcherMock do
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

  def fetch_xml(result, params \\ [])

  def fetch_xml("500", _params) do
    {:error, "HTTP status: 500"}
  end

  def fetch_xml(xml, _params) do
    {:ok, xml}
  end
end
