defmodule Npricot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    
    file_path = Application.get_env(:npricot, :watched_file_path, "/Volumes/Macintosh HD/Users/kim/Repositories/Developing/npricot/sample_repo/202401151030.md")
    
    children = [
      NpricotWeb.Telemetry,
      Npricot.Repo,
      {DNSCluster, query: Application.get_env(:npricot, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Npricot.PubSub},
      {Npricot.FileSystem.Watcher, file_path},
      # Start a worker by calling: Npricot.Worker.start_link(arg)
      # {Npricot.Worker, arg},
      # Start to serve requests, typically the last entry
      NpricotWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Npricot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NpricotWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
