defmodule DashWeb.TimerLive do
  use DashWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Dash.Timer.subscribe()
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, socket |> assign(id: params["id"], timer_status: :running)}
  end

  @impl true
  def handle_event("stop", _unsigned_params, socket) do
    Dash.Timer.stop_timer(Dash.Timer)
    {:noreply, assign(socket, timer_status: :stopped)}
  end

  @impl true
  def handle_event("start", _unsigned_params, socket) do
    Dash.Timer.start_timer(Dash.Timer)
    {:noreply, assign(socket, timer_status: :running)}
  end

  @impl true
  def handle_info(:timer_updated, socket) do
    {timer_status} = Dash.Timer.get_timer_state(Dash.Timer)
    {:noreply, assign(socket, timer_status: timer_status)}
  end
end
