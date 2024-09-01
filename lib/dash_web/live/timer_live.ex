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

    {:ok, socket |> assign(id: timer_id, state: timer.state)}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("stop", _unsigned_params, socket) do
    # todo: move upd db timer + notification to separate service layer, mb gen_stage
    Dash.Timers.Timer
    |> where(id: ^socket.assigns.id)
    |> where(state: :running)
    |> Repo.one!()
    |> Dash.Timers.change_timer(%{state: :stopped})
    |> Repo.update!()

    Dash.TimerPubSub.timer_changed(socket.assigns.id, %{state: :stopped})

    {:noreply, assign(socket, state: :stopped)}
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
  def handle_info(%{state: state}, socket) do
    {:noreply, assign(socket, state: state)}
  end
end
