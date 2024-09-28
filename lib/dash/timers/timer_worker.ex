defmodule Dash.Timers.Timer do
  use GenServer

  def start_link(name, args) do
    GenServer.start_link(__MODULE__, args, name: {:via, Registry, {Dash.Timers.Registry, name}})
  end

  @impl true
  def init({
        name,
        state = %{
          time_left: _time_left
        }
      }) do
    {:ok, Map.merge(state, %{state: :stopped, id: name})}
  end

  def stop(id) do
    GenServer.call({:via, Registry, {Dash.Timers.Registry, id}}, :stop)
  end

  def run(id) do
    GenServer.call({:via, Registry, {Dash.Timers.Registry, id}}, :run)
  end

  def get(id) do
    GenServer.call({:via, Registry, {Dash.Timers.Registry, id}}, :get)
  end

  @impl true
  def handle_call(:get, _from, state) do
    time_left = time_left(state)
    {:reply, %{state | :time_left => time_left}, state}
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
          id: id,
          time_left: _time_left,
          started_at: _started_at,
          state: :running
        } = state
      ) do
    tl = time_left(state)

    new_state = %{
      id: id,
      time_left: tl,
      state: :stopped,
      started_at: nil
    }

    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(:run, _from, %{state: :running} = state) do
    time_left = time_left(state)
    {:reply, %{state | :time_left => time_left}, state}
  end

  @impl true
  def handle_call(:run, _from, %{id: id, time_left: time_left}) do
    started_at = DateTime.utc_now()

    new_state = %{
      id: id,
      time_left: time_left,
      state: :running,
      started_at: started_at
    }

    {:reply, new_state, new_state}
  end

  defp time_left(%{state: :stopped, time_left: time_left}) do
    time_left
  end

  defp time_left(%{state: :running, time_left: time_left, started_at: started_at}) do
    diff =
      DateTime.diff(DateTime.utc_now(), started_at, :second)

    diffTime = Time.from_seconds_after_midnight(diff)

    if Time.compare(diffTime, time_left) == :gt do
      ~T[00:00:00]
    else
      Time.add(time_left, -diff, :second)
    end
  end
end
