defmodule Dash.Topic.PubSub do
  @moduledoc """
  Convinience functions for subscribing and publishing to MQTT topics.
  """
  alias Phoenix.PubSub
  require Logger

  def subscribe(device) do
    PubSub.subscribe(Dash.PubSub, "mqtt/#{device}")
  end

  @spec publish(binary(), term()) :: :ok | {:error, any()}
  def publish(device, msg) do
    try do
      [{db, _value}] = Registry.lookup(Dash.ProcRegistry, :rootdb)
      CubDB.put(db, device, msg)
      PubSub.broadcast(Dash.PubSub, "mqtt/#{device}", msg)
    rescue
      error ->
        Logger.error(error: error)
        :ok
    end
  end
end
