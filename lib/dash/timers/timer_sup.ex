defmodule Dash.Timers.Supervisor do
  alias Dash.Idseq.Idseq
  alias Dash.Timers.Timer

  @moduledoc """
  Dynamically creates timers. If timer exits/crashes, it is not restarted.
  """

  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_child(state) do
    id = Idseq.next_id()

    spec = %{
      id: Timer,
      start: {Timer, :start_link, [id, state]},
      restart: :transient
    }

    case DynamicSupervisor.start_child(__MODULE__, spec) do
      {:ok, _pid} ->
        {:ok, %{id: id}}

      {:error, reason} ->
        {:error, reason}
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
