defmodule Dash.Topic.Listener do
  @moduledoc """
  Listener for MQTT messages. Ignores everything except messages from zigbee2mqtt,
  which are then published to the appropriate PubSub topic.
  """

  require Logger
  alias Dash.Topic.PubSub

  @behaviour ExMQTT.PublishHandler

  @impl true
  def handle_publish(%{payload: _payload, topic: "zigbee2mqtt/bridge/" <> topic}, _extra) do
    Logger.warning("Received message on bridge topic, ignoring", topic: topic)
    :ok
  end

  @impl true
  def handle_publish(%{payload: payload, topic: "zigbee2mqtt/" <> topic}, _extra) do
    log_topic = "zigbee2mqtt/#{topic}"
    logctx = [topic: log_topic]

    case String.split(topic, "/") do
      [device, "availability"] ->
        handle_availability_msg(String.downcase(device), payload, logctx)

      [device] ->
        handle_device_msg(String.downcase(device), payload, logctx)

      _ ->
        Logger.error("Invalid topic name, ignoring", logctx)
    end

    :ok
  end

  @impl true
  def handle_publish(%{payload: _payload, topic: topic}, _extra) do
    Logger.warning("Received message on topic, ignoring", topic: topic)
    :ok
  end

  defp handle_device_msg(device, msg, logctx) do
    case Jason.decode(msg) do
      {:ok,
       %{
         "battery" => battery,
         "contact" => contact
       }} ->
        PubSub.publish(String.downcase(device), %{
          battery: battery,
          contact: contact,
          received: Time.utc_now()
        })

      {:ok, _msg} ->
        Logger.error("Unsupported message format", logctx)

      {:error, _} ->
        Logger.error("Invalid JSON payload, ignoring", logctx)
    end
  end

  defp handle_availability_msg(device, msg, logctx) do
    case msg do
      "online" ->
        PubSub.publish(String.downcase(device), %{
          available: true,
          received: Time.utc_now()
        })

      "offline" ->
        PubSub.publish(String.downcase(device), %{
          available: false,
          received: Time.utc_now()
        })

      _ ->
        Logger.error("can't process unknown availability message: #{msg}", logctx)
    end
  end
end
