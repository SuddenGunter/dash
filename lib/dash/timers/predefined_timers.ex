defmodule Dash.Timers.PredefinedTimers do
  use Agent

  def start_link(opts) do
    {initial_value, _opts} = Keyword.pop(opts, :initial_value, 0)
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  def get do
    Agent.get(__MODULE__, & &1)
  end

  def set(x) do
    Agent.update(__MODULE__, fn _ -> Enum.sort(x) end)
  end
end
