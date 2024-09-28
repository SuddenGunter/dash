defmodule Dash.Idseq.Idseq do
  @moduledoc """
  ID sequence generator. Generates unique IDs for timers.
  """
  use GenServer

  def start_link([]) do
    sqids = Sqids.new!()

    GenServer.start_link(
      __MODULE__,
      %{last_id: DateTime.to_unix(DateTime.utc_now(), :microsecond), sqids: sqids},
      name: __MODULE__
    )
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  def next_id do
    GenServer.call(__MODULE__, :next_id)
  end

  @impl true
  def handle_call(:next_id, _from, %{last_id: last_id, sqids: sqids}) do
    # credo:disable-for-next-line
    # TODO: not a secure approach for public-facing IDs, but ok for now
    new_last_id = last_id + 1
    result_id = Sqids.encode!(sqids, [new_last_id])

    {:reply, result_id, %{last_id: new_last_id, sqids: sqids}}
  end
end
