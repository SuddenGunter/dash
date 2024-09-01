defmodule DashWeb.HomeController do
  use DashWeb, :controller
  require Logger

  def home(conn, _params) do
    render(conn, :home)
  end

  @spec timer(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def timer(conn, _params) do
    case Dash.Timers.create_timer(%{:time_left => Time.new!(0, 30, 0), :state => :stopped}) do
      {:ok, x} ->
        Plug.Conn.put_status(conn, 303)
        redirect(conn, to: ~p"/timer/#{x.id}")

      {:error, details} ->
        Logger.error("failed to start timer", details)
    end
  end
end
