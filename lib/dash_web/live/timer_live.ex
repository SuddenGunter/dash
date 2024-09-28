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

    {:ok, socket |> assign(id: timer_id, state: timer.state, time_left: timer.time_left)}
  end

  @impl true
  @spec handle_params(any(), any(), any()) :: {:noreply, any()}
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("stop", _unsigned_params, socket) do
    timer = Dash.Timers.Timer.stop(socket.assigns.id)

    values = %{
      state: :stopped,
      time_left: timer.time_left
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
    timer = Dash.Timers.Timer.stop(socket.assigns.id)

    values = %{
      state: :running,
      time_left: timer.time_left
    }

    {:noreply, assign(socket, values)}
  end

  @impl true
  def handle_info(%{state: state, time_left: time_left}, socket) do
    {:noreply, assign(socket, %{state: state, time_left: time_left})}
  end
end
