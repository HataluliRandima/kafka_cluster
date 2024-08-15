defmodule KafkaCluster.Kaffe.Producer do
  require Logger

  def send_my_message({key, value}, topic, times \\ 1) when is_integer(times) and times > 0 do
    value = encode_message(value)

    start_time = :os.system_time(:millisecond)

    Enum.each(1..times, fn _ ->
      Kaffe.Producer.produce_sync(topic, [{key, value}])
    end)

    end_time = :os.system_time(:millisecond)
    duration = end_time - start_time

    Logger.info("Sent message to topic #{topic} in #{duration} ms", log: :pr)
    Logger.info("Sent message to topic #{topic} with value :: #{inspect value}", log: :pr)
    Logger.info("Sent #{times} messages to topic #{topic} in #{duration} ms")
  end

  defp encode_message(message) do
   Jason.encode!(message)
  end

end
