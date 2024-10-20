defmodule Dash.Topic.Listener do
  require Logger
  alias Dash.Topic.PubSub

  @behaviour ExMQTT.PublishHandler

  @impl true
  def handle_publish(%{payload: payload, topic: "zigbee2mqtt/" <> topic}, _extra) do
    log_topic = "zigbee2mqtt/#{topic}"

    if valid_device_name(topic) do
      case Jason.decode(payload) do
        {:ok, msg} -> PubSub.publish(String.downcase(topic), msg)
        {:error, _} -> Logger.error("Invalid JSON payloadd, ignoring", topic: log_topic)
      end
    else
      Logger.error("Invalid device name, ignoring", topic: log_topic)
    end

    :ok
  end

  @impl true
  def handle_publish(%{payload: _payload, topic: topic}, _extra) do
    Logger.debug("Received message on topic, ignoring", topic: topic)
    :ok
  end

  defp valid_device_name(device) do
    String.contains?(device, "/") == false
  end
end
