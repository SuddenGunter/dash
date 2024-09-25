defmodule Dash.Timers.DynamicSupervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  # TODO: use options pattern
  def start_child(state) do
    # TODO: proper ID generation / squids
    unix_time = System.system_time(:second)

    spec = %{
      id: Dash.Timers.Timer,
      start: {Dash.Timers.Timer, :start_link, [unix_time, {unix_time, state}]},
      restart: :transient
    }

    case DynamicSupervisor.start_child(__MODULE__, spec) do
      {:ok, _PID} ->
        {:ok, %{id: unix_time}}

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

  @impl true
  def handle_call(:stop, _from, %{
        id: id,
        time_left: time_left,
        state: _state
      }) do
    new_state = %{
      id: id,
      time_left: time_left,
      state: :stopped
    }

    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(:run, _from, %{
        id: id,
        time_left: time_left,
        state: _state
      }) do
    new_state = %{
      id: id,
      time_left: time_left,
      state: :running
    }

    {:reply, new_state, new_state}
  end
end
