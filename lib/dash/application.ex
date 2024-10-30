defmodule Dash.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    mqttconf = Application.get_env(:dash, :mqtt)

    children = [
      DashWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:dash, :dns_cluster_query) || :ignore},
      {Registry, [keys: :unique, name: Dash.Timers.Registry]},
      {Registry, [keys: :unique, name: Dash.CommonRegistry]},
      Dash.Idseq.Idseq,
      Dash.Timers.Supervisor,
      Dash.Topic.State,
      {Phoenix.PubSub, name: Dash.PubSub},
      {Dash.Security.Server, enabled: true}
    ]

    # poor man's feature flag
    children =
      if mqttconf[:enabled] == true do
        children ++
          [
            {ExMQTT.Supervisor,
             publish_handler: {Dash.Topic.Listener, []},
             host: mqttconf[:host],
             port: mqttconf[:port],
             username: mqttconf[:username],
             password: mqttconf[:password],
             subscriptions: mqttconf[:subscriptions]}
          ]
      else
        children
      end

    children =
      children ++
        [
          # Start the Finch HTTP client for sending emails
          {Finch, name: Dash.Finch},
          # Start a worker by calling: Dash.Worker.start_link(arg)
          # {Dash.Worker, arg},
          # Start to serve requests, typically the last entry
          DashWeb.Endpoint
        ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Dash.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DashWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
