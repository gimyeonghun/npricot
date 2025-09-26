defmodule NpricotWeb.PageController do
  use NpricotWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
