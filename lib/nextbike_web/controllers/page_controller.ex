defmodule NBCWeb.PageController do
  use NBCWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
