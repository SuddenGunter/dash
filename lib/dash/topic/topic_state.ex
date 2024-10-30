defmodule Dash.Topic.State do
  use Agent

  @proc {:via, Registry, {Dash.CommonRegistry, __MODULE__}}

  def(start_link(_args)) do
    Agent.start_link(fn -> [] end, name: @proc)
  end

  def get(topic) do
    Agent.get(@proc, fn state ->
      Enum.filter(state, fn {t, _m} -> t == topic end)
      |> Enum.map(fn {_t, m} -> m end)
    end)
  end

  def save(topic, msg) do
    Agent.update(@proc, fn state ->
      [{topic, msg} | state]
    end)
  end

  def topics do
    Agent.get(@proc, fn state ->
      Enum.map(state, fn {k, _v} -> k end)
      |> Enum.dedup()
    end)
  end
end
