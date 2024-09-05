defmodule DashWeb.TimerLive do
  require Logger
  alias Dash.Repo
  use DashWeb, :live_view
  import Ecto.Query

  @impl true
  def mount(params, _session, socket) do
    timer_id = params["id"]
    timer = Dash.Timers.get_timer!(timer_id)

    if connected?(socket), do: Dash.TimerPubSub.subscribe(timer_id)

    {:ok, socket |> assign(id: timer_id, state: timer.state, time_left: time_left(timer))}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("stop", _unsigned_params, socket) do
    # todo: move upd db timer + notification to separate service layer, mb gen_stage
    timer =
      Dash.Timers.Timer
      |> where(id: ^socket.assigns.id)
      |> where(state: :running)
      # todo: handle error, cause it's ok: timer can be already stopped by some other user
      |> Repo.one!()

    time_left = time_left(timer)

    # it's ok to do it as separate operation: optimistic lock will prevent concurrent updates
    timer
    |> Dash.Timers.change_timer(%{state: :stopped, time_left: time_left})
    |> Repo.update!()

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
    # todo: move upd db timer + notification to separate service layer, mb gen_stage

    timer =
      Dash.Timers.Timer
      |> where(id: ^socket.assigns.id)
      |> where(state: :stopped)
      |> Repo.one!()

    timer
    |> Dash.Timers.change_timer(%{state: :running, time_left: timer.time_left})
    |> Repo.update!()

    values = %{
      state: :running,
      time_left: timer.time_left
    }

    # for other users
    Dash.TimerPubSub.timer_changed(socket.assigns.id, values)

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

        Time.add(timer.time_left, -diff, :second)

      :stopped ->
        timer.time_left
    end
  end
end
