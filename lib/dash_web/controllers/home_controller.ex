defmodule DashWeb.HomeController do
  use DashWeb, :controller
  require Logger

  def home(conn, _params) do
    render(conn, :home, form: Phoenix.Component.to_form(%{}))
  end

  @spec timer(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def timer(conn, _params) do
    # case Dash.Timers.create_timer(%{:time_left => Time.new!(0, 30, 0), :state => :stopped}) do
    case Dash.Timers.Supervisor.start_child(%{
           time_left: Time.new!(0, 30, 0)
         }) do
      {:ok, x} ->
        Plug.Conn.put_status(conn, 303)
        # TODO: try Phoenix.LiveView.Controller
        redirect(conn, to: ~p"/timer/#{x.id}")

      {:error, reason} ->
        Logger.error(%{reason: reason})
        throw(:error)
    end
  end
end
