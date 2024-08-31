defmodule Dash.Timer do
  use Agent
  alias Phoenix.PubSub

  def start_link(opts) do
    Agent.start_link(fn -> {:stopped} end, opts)
  end

  def get_timer_state(timer) do
    Agent.get(timer, fn state -> state end)
  end

  def start_timer(timer) do
    Agent.update(timer, fn {_timer_status} -> {:running} end)
    notify()
  end

  def stop_timer(timer) do
    Agent.update(timer, fn {_timer_status} -> {:stopped} end)
    notify()
  end

  def subscribe() do
    PubSub.subscribe(Dash.PubSub, "liveview_stopwatch")
  end

  def notify() do
    PubSub.broadcast(Dash.PubSub, "liveview_stopwatch", :timer_updated)
  end
end
