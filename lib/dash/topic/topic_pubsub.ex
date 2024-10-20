defmodule Dash.Topic.PubSub do
  alias Phoenix.PubSub
  require Logger

  def subscribe(device) do
    PubSub.subscribe(Dash.PubSub, "mqtt/#{device}")
  end

  @spec publish(binary(), term()) :: :ok | {:error, any()}
  def publish(device, msg) do
    PubSub.broadcast(Dash.PubSub, "mqtt/#{device}", msg)
  end
end
