defmodule Dash.Timers.Supervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  # TODO: use options pattern
  def start_child(state) do
    # TODO: proper ID generation / squids
    unix_time = System.system_time(:second)
    id = Integer.to_string(unix_time)

    spec = %{
      id: Dash.Timers.Timer,
      start: {Dash.Timers.Timer, :start_link, [id, {unix_time, state}]},
      restart: :transient
    }

    case DynamicSupervisor.start_child(__MODULE__, spec) do
      {:ok, _PID} ->
        {:ok, %{id: id}}

      {:error, reason} ->
        {:error, reason}
        # TODO with
    end
  end

  @impl true
  @spec init(any()) ::
          {:ok,
           %{
             extra_arguments: list(),
             intensity: non_neg_integer(),
             max_children: :infinity | non_neg_integer(),
             period: pos_integer(),
             strategy: :one_for_one
           }}
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end

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
    with_updated_time = Map.put(state, :time_left, time_left)
    {:reply, with_updated_time, state}
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
    with_updated_time = Map.put(state, :time_left, time_left)
    {:reply, with_updated_time, state}
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
