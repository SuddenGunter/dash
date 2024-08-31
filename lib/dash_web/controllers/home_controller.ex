defmodule DashWeb.HomeController do
  use DashWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
