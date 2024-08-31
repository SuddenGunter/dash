defmodule DashWeb.TimerLive do
  use DashWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      IO.puts("CONNECTED")
    else
      IO.puts("DISCONNECTED")
    end

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, socket |> assign(id: params["id"], timer_status: :running)}
  end

  def handle_event("stop", _unsigned_params, socket) do
    {:noreply, assign(socket, timer_status: :stopped)}
  end

  def handle_event("start", _unsigned_params, socket) do
    {:noreply, assign(socket, timer_status: :running)}
  end
end
