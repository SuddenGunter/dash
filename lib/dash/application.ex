defmodule Dash.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      DashWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:dash, :dns_cluster_query) || :ignore},
      {Registry, [keys: :unique, name: Dash.Timers.Registry]},
      Dash.Timers.DynamicSupervisor,
      {Phoenix.PubSub, name: Dash.PubSub},
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
