defmodule DashWeb.TimerLive do
  require Logger
  use DashWeb, :live_view

  @impl true
  def mount(params, _session, socket) do
    # TODO:
    # Ask dynamicSupervisor to start timer process (probably genserver or statem)
    # if it's already started - just return it
    # Monitor liveview from timer OR Link timer to liveview pid and if there are no more liveviews linked to timer for over 1 minute - kill timer
    # Process.send_after(self(), :timeout, 5000) schedules a message to be sent after 5 seconds.
    # Process.cancel_timer/1 cancels the scheduled message if you receive a :cancel message first.

    timer_id = params["id"]
    timer = Dash.Timers.Timer.get(timer_id)

    if connected?(socket), do: Dash.TimerPubSub.subscribe(timer_id)

    {:ok, socket |> assign(id: timer_id, state: timer.state, time_left: time_left(timer))}
  end

  @impl true
  @spec handle_params(any(), any(), any()) :: {:noreply, any()}
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("stop", _unsigned_params, socket) do
    timer = Dash.Timers.Timer.get(socket.assigns.id)
    time_left = time_left(timer)

    # it's ok to do it as separate operation: optimistic lock will prevent concurrent updates
    Dash.Timers.Timer.stop(socket.assigns.id, time_left)

    values = %{
      state: :stopped,
      time_left: time_left
    }

    # for other users
    Dash.TimerPubSub.timer_changed(socket.assigns.id, values)

    {:noreply, assign(socket, values)}
  end

  @impl true
  def handle_event("start", _unsigned_params, socket) do
    timer = Dash.Timers.Timer.get(socket.assigns.id)

    Dash.Timers.Timer.run(socket.assigns.id)

    values = %{
      state: :running,
      time_left: timer.time_left
    }

    # for other users
    Dash.TimerPubSub.timer_changed(socket.assigns.id, values)

    {:noreply, assign(socket, values)}
  end

  @impl true
  def handle_event("timer_live__completed", _params, socket) do
    # TODO: what if client already sent an event, but the timer is not yet expired?
    timer = Dash.Timers.Timer.get(socket.assigns.id)

    time_left = time_left(timer)

    Dash.Timers.Timer.stop(socket.assigns.id, time_left)

    values = %{
      state: :running,
      time_left: time_left
    }

    {:noreply, assign(socket, values)}
  end

  @impl true
  def handle_info(%{state: state, time_left: time_left}, socket) do
    {:noreply, assign(socket, %{state: state, time_left: time_left})}
  end

  defp time_left(timer) do
    case timer.state do
      :running ->
        diff =
          DateTime.diff(DateTime.utc_now(), timer.updated_at, :second)

        Logger.info("timer.updated_at: #{timer.updated_at}")
        diffTime = Time.from_seconds_after_midnight(diff)

        if Time.compare(diffTime, timer.time_left) == :gt do
          ~T[00:00:00]
        else
          Time.add(timer.time_left, -diff, :second)
        end

      :stopped ->
        timer.time_left
    end
  end
end
