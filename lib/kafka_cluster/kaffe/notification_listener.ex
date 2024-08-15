defmodule KafkaCluster.Kaffe.NotificationListener do
  use GenServer
  require Logger
  alias Ecto.Adapters.SQL
  alias KafkaCluster.Repo

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    # Start listening to the "new_charge" channel
    SQL.query!(Repo, "LISTEN new_charge;")
    Logger.info("Started listening on new_charge channel 2 module", log: :pr)

    # Initialize the counter in the state
    {:ok, %{counter: 0}}
  end

  def handle_info({:notification, _pid, _ref, _channel, payload}, state) do
    # Assuming the payload is a JSON string, decode it
    case Jason.decode(payload) do
      {:ok, decoded_payload} ->
        IO.puts("Received notification with payload:")
        IO.inspect(decoded_payload)

        # Increment the counter
        new_counter = state.counter + 1
        Logger.info("Notification count: #{new_counter}", log: :pr)

        # Publish the decoded payload to a Kafka topic
        # KafkaCluster.Kaffe.Producer.send_my_message({"charge_key", decoded_payload}, "kafka-topic-test")

        # Update the state with the new counter value
        {:noreply, %{state | counter: new_counter}}

      {:error, _reason} ->
        Logger.error("Failed to decode JSON payload: #{payload}")
        {:noreply, state}
    end
  end

  def handle_info(msg, state) do
    Logger.info("Received an unexpected message: #{inspect(msg)}", log: :pr)
    {:noreply, state}
  end
end
