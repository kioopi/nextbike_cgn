defmodule NBC.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      NBCWeb.Telemetry,
      NBC.Repo,
      {DNSCluster, query: Application.get_env(:nextbike, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: NBC.PubSub},
      # Start a worker by calling: NBC.Worker.start_link(arg)
      # {NBC.Worker, arg},
      # Start Oban for background job processing
      {Oban,
       AshOban.config(
         Application.fetch_env!(:nextbike, :ash_domains),
         Application.fetch_env!(:nextbike, Oban)
       )},
      # Start to serve requests, typically the last entry
      NBCWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NBC.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NBCWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
