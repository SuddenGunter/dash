defmodule Dash.Topic.PubSub do
  alias Dash.Topic.State

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
    State.save(device, msg)
    PubSub.broadcast(Dash.PubSub, "mqtt/#{device}", msg)
  end
end
