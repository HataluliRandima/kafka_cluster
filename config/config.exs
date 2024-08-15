# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :kafka_cluster,
  ecto_repos: [KafkaCluster.Repo]

# Configures the endpoint
config :kafka_cluster, KafkaClusterWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: KafkaClusterWeb.ErrorHTML, json: KafkaClusterWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: KafkaCluster.PubSub,
  live_view: [signing_salt: "LMqR2+nQ"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :kafka_cluster, KafkaCluster.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# config :logger,
#   backends: [:console, {LoggerFileBackend, :file_log}],
#   format: "$time $metadata[$level] $message\n",
#   metadata: :all


  # Configures Elixir's Logger
config :logger, :console,
format: "$date $time $metadata[$level] $message\n",
metadata: [:request_id, :all]

#config :logger, utc_log: true
config :logger, backends: [
:console,
                          {LoggerFileBackend, :info},
                          {LoggerFileBackend, :file_log}
                        ]
max_bytes = 500_000_000

config :logger, :file_log,
  path: "logs/file.log",
  level: :info

config :logger, :info,
  metadata: [:application, :module, :pid],
  path: "logs/producer.log",
  format: "$date $time [$level] [$metadata] $message\n",
  level: :info,
  metadata_filter: [log: :pr],
  rotate: %{max_bytes: max_bytes, keep: 5}


  # config :kaffe,
  # producer: [
  #   # heroku_kafka_env: true,
  #   endpoints: [{'13.40.7.67', 9092}],
  #   topics: ["kafka-topic-test"],
  #   linger_ms: 10,
  #   batch_size: 1000

  #   # # optional
  #   # partition_strategy: :md5
  # ]

  config :kaffe,
  producer: [
    endpoints: [{'13.40.7.67', 9092},],   # Kafka broker endpoints
    topics: ["kafka-topic-test"],         # Topics to publish to
    # partition_strategy: :round_robin,    # Partition strategy: :round_robin, :random, :consistent_hash
    compression: :gzip,                  # Compression type: :none, :gzip, :snappy, :lz4, :zstd
    required_acks: 1,                    # Acknowledgment: 0, 1, -1 (all)
    max_retries: 5,                      # Max number of retries on failure
    retry_backoff_ms: 100,               # Backoff time between retries (milliseconds)
    batch_size: 100_000,                 # Maximum number of messages per batch
    linger_ms: 50,                       # Time to wait before sending a batch (milliseconds)
    max_batch_bytes: 10_000_000,         # Maximum size of a batch (in bytes)
    client_id: "elixir_client",     # Client ID to identify the producer
    timeout: 15_000,                     # Request timeout in milliseconds
    request_timeout: 30_000,             # Timeout for producer requests (milliseconds)
    metadata_refresh_interval_ms: 600_000, # How often to refresh metadata (milliseconds)
    # sasl: [
    #   mechanism: :plain,                 # SASL authentication mechanism (e.g., :plain, :scram_sha256, :scram_sha512)
    #   username: "your-username",         # SASL username
    #   password: "your-password"          # SASL password
    # ],
    # ssl: [
    #   enable: false,                     # Enable SSL (true or false)
    #   cacertfile: "path/to/ca-cert.pem", # Path to CA certificate
    #   certfile: "path/to/cert.pem",      # Path to client certificate
    #   keyfile: "path/to/key.pem"         # Path to client private key
    # ],
    log_level: :info                     # Log level: :debug, :info, :warn, :error
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.3.2",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
# config :logger, :console,
#   format: "$time $metadata[$level] $message\n",
#   metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
