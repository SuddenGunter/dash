defmodule Dash.Security.Server do
  @moduledoc """
  Security server module, contains state of security server. Can be enabled and disabled.
  Knows if the system is in alarmed state or not.
  If the system is alarmed sends external notification to the user (only if security server enabled, or as soon as it's enabled if it was alarmed before).

  Current implementation does not have any throttling or rate limiting: it will send all alarm notifications as soon as possible.
  """
  require Logger
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, {__MODULE__, args},
      name: {:via, Registry, {Dash.CommonRegistry, __MODULE__}}
    )
  end

  @impl true
  def init({Dash.Security.Server, enabled: enabled}) do
    {:ok, %{enabled: enabled}}
  end

  def enable do
    GenServer.call({:via, Registry, {Dash.CommonRegistry, __MODULE__}}, :enable)
  end

  def disable do
    GenServer.call({:via, Registry, {Dash.CommonRegistry, __MODULE__}}, :disable)
  end

  def enabled? do
    GenServer.call({:via, Registry, {Dash.CommonRegistry, __MODULE__}}, :enabled?)
  end

  @impl true
  def handle_call(:enable, _from, state) do
    {:reply, :ok, %{state | enabled: true}}
  end

  @impl true
  def handle_call(:disable, _from, state) do
    {:reply, :ok, %{state | enabled: false}}
  end

  @impl true
  def handle_call(:enabled?, _from, state) do
    {:reply, state.enabled, state}
  end
end
