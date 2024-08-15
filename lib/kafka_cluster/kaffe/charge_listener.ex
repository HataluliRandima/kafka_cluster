defmodule KafkaCluster.Kaffe.ChargeListener do
  use GenServer

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, _conn} = Postgrex.Notifications.start_link(name: :notifications, hostname: "10.10.10.168",
      username: "postgres",
      password: "postgres",
      database: "rpt_01_dev")

    Logger.info("ChargeListener started and listening for new_charge notifications", log: :pr)
      # Postgrex.Notifications.listen(:notifications, "new_charge")

        # Start listening to the "new_charge" channel
    case Postgrex.Notifications.listen(:notifications, "new_charge") do
      :ok ->
        Logger.info("Successfully listening to the new_charge channel", log: :pr)
      {:error, reason} ->
        Logger.error("Failed to listen to the new_charge channel: #{inspect(reason)}", log: :pr)
    end

    {:ok, %{counter: 0}}
  end

    def handle_info({:notification, _pid, _ref, _channel, payload}, state) do
      # Assuming the payload is a JSON string, you might need to decode it first
      # decoded_payload = Jason.decode!(payload)
      # # IO.puts "Test check"
      # # IO.inspect decoded_payload
      # Logger.info("Payload :: #{inspect payload}", log: :pr)
      # Logger.info("Decoded Payload :: #{inspect decoded_payload}", log: :pr)
      # KafkaCluster.Kaffe.Producer.send_my_message({"charge_key", decoded_payload}, "kafka-topic-test")

    # Assuming the payload is a JSON string, you might need to decode it first
     case Jason.decode(payload) do
      {:ok, decoded_payload} ->
        Logger.info("Received notification with payload :: #{inspect decoded_payload}", log: :pr)
        # Increment the counter
        new_counter = state.counter + 1
        Logger.info("Notification count: #{new_counter}", log: :pr)
        # Publish the decoded payload to a Kafka topic
        KafkaCluster.Kaffe.Producer.send_my_message({"charge_key", decoded_payload}, "kafka-topic-test")
        # Update the state with the new counter value
        {:noreply, %{state | counter: new_counter}}
      {:error, reason} ->
        Logger.error("Failed to decode error :: #{inspect(reason)} JSON payload: #{payload}", log: :pr)
        {:noreply, state}
     end


    # {:noreply, state}
    end

    def handle_info(msg, state) do
      Logger.info("Received an unexpected message: #{inspect(msg)}", log: :pr)
      {:noreply, state}
    end

end
