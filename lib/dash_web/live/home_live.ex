defmodule DashWeb.HomeLive do
  require Logger
  alias Dash.Timers.PredefinedTimers
  use DashWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    timers = PredefinedTimers.get()

    {:ok,
     assign(socket,
       timer_form: Phoenix.Component.to_form(%{}),
       timer_settings_form: Phoenix.Component.to_form(%{}),
       timers: Enum.map(timers, &format_timer/1)
     )}
  end

  defp format_timer(minutes) when is_number(minutes) do
    {minutes, Time.from_seconds_after_midnight(60 * minutes) |> Time.to_string()}
  end

  @impl true
  def handle_event("submit_timer", %{"duration" => duration}, socket) do
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

    {:noreply, push_navigate(socket, to: ~p"/timer/#{timer.id}")}
  end

  @impl true
  def handle_event("submit_timer_settings", values, socket) do
    timers =
      Map.values(values)
      |> Enum.filter(&(&1 != ""))
      |> Enum.map(fn x ->
        {num, _rem} = Integer.parse(x)
        num
      end)

    PredefinedTimers.set(timers)
    {:noreply, assign(socket, timers: Enum.sort(timers) |> Enum.map(&format_timer/1))}
  end
end
