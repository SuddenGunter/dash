defmodule Dash.Timers.PubSub do
  @moduledoc """
  PubSub module for timers. Allows multiple users to know if timer was stopped or started.
  """
  alias Phoenix.PubSub

  def timer_changed(timer_id, msg) do
    notify(timer_id, msg)
  end

  def subscribe(timer_id) do
    PubSub.subscribe(Dash.PubSub, "timer:#{timer_id}")
  end

  defp notify(timer_id, msg) do
    PubSub.broadcast(Dash.PubSub, "timer:#{timer_id}", msg)
  end
end
