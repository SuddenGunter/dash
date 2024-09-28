defmodule DashWeb.HomeController do
  use DashWeb, :controller
  require Logger

  def home(conn, _params) do
    render(conn, :home, form: Phoenix.Component.to_form(%{}))
  end

  @spec timer(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def timer(conn, %{"duration" => duration}) do
    duration =
      case Integer.parse(duration) do
        {num, _} when duration > 0 ->
          num

        _ ->
          raise ArgumentError, "Invalid duration"
      end

    {:ok, timer} =
      Dash.Timers.Supervisor.start_child(%{
        time_left: Time.from_seconds_after_midnight(duration * 60)
      })

    Plug.Conn.put_status(conn, 303)
    redirect(conn, to: ~p"/timer/#{timer.id}")
  end
end
