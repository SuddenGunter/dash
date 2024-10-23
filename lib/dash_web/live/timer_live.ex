defmodule DashWeb.TimerLive do
  require Logger
  alias Dash.Timers.PubSub
  alias Dash.Timers.Timer
  use DashWeb, :live_view

  @impl true
  @spec mount(nil | maybe_improper_list() | map(), any(), Phoenix.LiveView.Socket.t()) ::
          {:ok, any()}
  def mount(params, _session, socket) do
    timer_id = params["id"]

    case Timer.get(timer_id) do
      {:error, :not_found} ->
        {:ok,
         socket
         |> put_flash(:error, "Timer not found: it may have expired or been deleted.")
         |> redirect(to: ~p"/")}

      {:error, err} ->
        Logger.error("Error getting timer: #{inspect(err)}, timer_id: #{timer_id}")

        {:ok,
         socket
         |> put_flash(
           :error,
           "Unknown error, provider #{timer_id} to developer so we could fix it."
         )
         |> redirect(to: ~p"/")}

      timer ->
        if connected?(socket) do
          Timer.observe(timer_id, self())
          PubSub.subscribe(timer_id)
        end

        {:ok, socket |> assign(id: timer_id, state: timer.state, time_left: timer.time_left)}
    end
  end

  @impl true
  @spec handle_params(any(), any(), any()) :: {:noreply, any()}
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("stop", _unsigned_params, socket) do
    timer = Timer.stop(socket.assigns.id)

    # we return updated state ASAP, even though technically it might be also updated by handle_info callback
    {:noreply,
     assign(
       socket,
       %{
         state: :stopped,
         time_left: timer.time_left
       }
     )}
  end

  @impl true
  def handle_event("start", _unsigned_params, socket) do
    timer = Timer.run(socket.assigns.id)

    # we return updated state ASAP, even though technically it might be also updated by handle_info callback
    {:noreply,
     assign(socket, %{
       state: :running,
       time_left: timer.time_left
     })}
  end

  @impl true
  def handle_event("timer_live__completed", _params, socket) do
    timer = Timer.stop(socket.assigns.id)

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
