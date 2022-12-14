defmodule Drums.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      # Drums.Repo,
      # Start the Telemetry supervisor
      DrumsWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Drums.PubSub},
      # Start the Endpoint (http/https)
      DrumsWeb.Endpoint,
      # Start a worker by calling: Drums.Worker.start_link(arg)
      # {Drums.Worker, arg}
      Drums.Machines.MachineState,
      DrumsWeb.Presence
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Drums.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DrumsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
