defmodule GqlRepro.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GqlReproWeb.Telemetry,
      GqlRepro.Repo,
      {DNSCluster, query: Application.get_env(:gql_repro, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: GqlRepro.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: GqlRepro.Finch},
      # Start a worker by calling: GqlRepro.Worker.start_link(arg)
      # {GqlRepro.Worker, arg},
      # Start to serve requests, typically the last entry
      GqlReproWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GqlRepro.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GqlReproWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
