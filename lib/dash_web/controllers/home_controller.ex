defmodule DashWeb.HomeController do
  use DashWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  @spec timer(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def timer(conn, %{"duration" => duration}) do
    # todo: generate unique id
    # todo: insert into db
    # todo redirect to liveview with unique id in path
    # until then we use duration as id just for test
    Plug.Conn.put_status(conn, 303)
    redirect(conn, to: ~p"/timer/#{duration}")
  end
end
