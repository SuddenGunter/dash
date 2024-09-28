defmodule Dash.Timers.Supervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  # TODO: use options pattern
  def start_child(state) do
    id = Dash.Idseq.Idseq.next_id()

    spec = %{
      id: Dash.Timers.Timer,
      start: {Dash.Timers.Timer, :start_link, [id, state]},
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
