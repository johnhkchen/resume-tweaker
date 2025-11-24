defmodule ResumeTweaker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ResumeTweakerWeb.Telemetry,
      ResumeTweaker.Repo,
      {DNSCluster, query: Application.get_env(:resume_tweaker, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ResumeTweaker.PubSub},
      # Start a worker by calling: ResumeTweaker.Worker.start_link(arg)
      # {ResumeTweaker.Worker, arg},
      # Start to serve requests, typically the last entry
      ResumeTweakerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ResumeTweaker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ResumeTweakerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
