defmodule KafkaCluster.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  # import Supervisor.Spec

  @impl true
  @spec start(any(), any()) :: {:error, any()} | {:ok, pid()}
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      KafkaClusterWeb.Telemetry,
      # Start the Ecto repository
      KafkaCluster.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: KafkaCluster.PubSub},
      # Start Finch
      {Finch, name: KafkaCluster.Finch},
      # Start the Endpoint (http/https)
      KafkaClusterWeb.Endpoint,
      KafkaCluster.Kaffe.ChargeListener,
      KafkaCluster.Kaffe.NotificationListener
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KafkaCluster.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    KafkaClusterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
