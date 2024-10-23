defmodule Dash.Timers.Timer do
  @moduledoc """
  Timer module, contains state of a single timer. Can be started, stopped and observed.
  Stops itself if there are no observers or if it has been running for more than 12 hours.
  """
  require Logger
  use GenServer
  alias Dash.Timers.PubSub

  def start_link(name, args) do
    GenServer.start_link(__MODULE__, {name, args},
      name: {:via, Registry, {Dash.Timers.Registry, name}}
    )
  end

  @impl true
  def init({
        name,
        state = %{
          time_left: _time_left
        }
      }) do
    Logger.info(%{timer_id: name, state: state})
    Process.send_after(self(), :check_at_least_one_user, 10_000)

    {:ok, Map.merge(state, %{state: :stopped, id: name, observers: 0})}
  end

  def stop(id) do
    GenServer.call({:via, Registry, {Dash.Timers.Registry, id}}, :stop)
  end

  def run(id) do
    GenServer.call({:via, Registry, {Dash.Timers.Registry, id}}, :run)
  end

  def observe(id, observer) do
    GenServer.call({:via, Registry, {Dash.Timers.Registry, id}}, {:observe, observer})
  end

  def get(id) do
    GenServer.call({:via, Registry, {Dash.Timers.Registry, id}}, :get)
  end

  def handle_call(:get, _from, state) do
    time_left = time_left(state)
    {:reply, %{state | :time_left => time_left}, state}
  end

  @impl true
  def handle_call({:observe, observer}, _from, %{observers: observers} = state) do
    Process.monitor(observer)

    time_left = time_left(state)

    {:reply, %{state | :time_left => time_left}, %{state | :observers => observers + 1}}
  end

  @impl true
  def handle_call(:stop, _from, %{state: :stopped} = state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(
        :stop,
        _from,
        %{
          time_left: _time_left,
          started_at: _started_at,
          state: :running
        } = state
      ) do
    tl = time_left(state)

    new_state =
      Map.merge(state, %{
        time_left: tl,
        state: :stopped,
        started_at: nil
      })

    PubSub.timer_changed(new_state.id, %{
      state: :stopped,
      time_left: tl
    })

    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(:run, _from, %{state: :running} = state) do
    time_left = time_left(state)
    {:reply, %{state | :time_left => time_left}, state}
  end

  @impl true
  def handle_call(:run, _from, state) do
    started_at = DateTime.utc_now()

    new_state =
      Map.merge(state, %{
        state: :running,
        started_at: started_at
      })

    PubSub.timer_changed(new_state.id, %{
      state: :stopped,
      time_left: new_state.time_left
    })

    {:reply, new_state, new_state}
  end

  @impl true
  def handle_info({:DOWN, _, _, _, _}, state) do
    new_observers = state.observers - 1

    if new_observers == 0 do
      Process.send_after(self(), :check_at_least_one_user, 15_000)

      {:noreply, %{state | :observers => new_observers}}
    else
      {:noreply, %{state | :observers => new_observers}}
    end
  end

  @impl true
  def handle_info(:check_at_least_one_user, state) do
    if state.observers == 0 do
      Logger.info(%{timer_id: state.id, msg: "Timer has no observers, stopping"})
      {:stop, :normal, state}
    else
      # no timer can live over 12h, even if there are observers
      Process.send_after(self(), :timeout, 43_200_000)
      {:noreply, state}
    end
  end

  @impl true
  def handle_info(:timeout, state) do
    Logger.error("Timer #{state.id} has timed out")
    {:stop, :timeout, state}
  end

  defp time_left(%{state: :stopped, time_left: time_left}) do
    time_left
  end

  defp time_left(%{state: :running, time_left: time_left, started_at: started_at}) do
    diff =
      DateTime.diff(DateTime.utc_now(), started_at, :second)

    diff_time = Time.from_seconds_after_midnight(diff)

    if Time.compare(diff_time, time_left) == :gt do
      ~T[00:00:00]
    else
      Time.add(time_left, -diff, :second)
    end
  end
end
