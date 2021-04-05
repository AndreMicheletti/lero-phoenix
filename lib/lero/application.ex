defmodule Lero.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Lero.Repo,
      # Start the Telemetry supervisor
      LeroWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Lero.PubSub},
      # Start the Endpoint (http/https)
      LeroWeb.Endpoint
      # Start a worker by calling: Lero.Worker.start_link(arg)
      # {Lero.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Lero.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    LeroWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
