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

    {:ok, socket |> assign(id: timer_id, state: timer.state, time_left: timer.time_left)}
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

    Dash.TimerPubSub.timer_changed(socket.assigns.id, %{
      state: :stopped,
      time_left: timer.time_left
    })

    {:noreply, assign(socket, state: :stopped, time_left: time_left)}
  end

  @impl true
  def handle_event("start", _unsigned_params, socket) do
    # todo: move upd db timer + notification to separate service layer, mb gen_stage

    Dash.Timers.Timer
    |> where(id: ^socket.assigns.id)
    |> where(state: :stopped)
    |> Repo.one!()
    |> Dash.Timers.change_timer(%{state: :running})
    |> Repo.update!()

    Dash.TimerPubSub.timer_changed(socket.assigns.id, %{state: :running})

    {:noreply, assign(socket, state: :running)}
  end

  @impl true
  def handle_info(%{state: state, time_left: time_left}, socket) do
    {:noreply, assign(socket, state: state, time_left: time_left)}
  end

  @impl true
  @spec handle_info(%{:state => any(), optional(any()) => any()}, any()) :: {:noreply, any()}
  def handle_info(%{state: state}, socket) do
    {:noreply, assign(socket, state: state)}
  end

  defp time_left(timer) do
    diff =
      DateTime.diff(DateTime.utc_now(), timer.updated_at, :second)

    Time.add(timer.time_left, -diff, :second)
  end
end
