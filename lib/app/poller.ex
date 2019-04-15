defmodule App.Poller do
  use GenServer
  require Logger

  @polling_timeout 1000

  # Server

  def start_link do
    Logger.log :info, "Started poller"
    GenServer.start_link __MODULE__, :ok, name: __MODULE__
  end

  def init(:ok) do
    {:ok, [], @polling_timeout}
  end

  def handle_cast(:update, _) do
    get_updates()

    {:noreply, [], @polling_timeout}
  end

  def handle_info(:timeout, _) do
    get_updates()

    {:noreply, [], @polling_timeout}
  end

  # Client
  
  def update do
    GenServer.cast __MODULE__, :update
  end

  # Helpers

  defp get_updates do
    offset = Agent.get(App.Offset, & &1)
    last_message_id = Nadia.get_updates([offset: offset])
      |> process_messages

    Agent.update(App.Offset, fn _ -> last_message_id + 1 end)
  end

  defp process_messages({:ok, []}), do: -1
  defp process_messages({:ok, results}) do
    results
    |> Enum.map(fn %{update_id: id} = message ->
      message
      |> process_message

      id
    end)
    |> List.last
  end
  defp process_messages({:error, %Nadia.Model.Error{reason: reason}}) do
    Logger.log :error, reason

    -1
  end
  defp process_messages({:error, error}) do
    Logger.log :error, error

    -1
  end

  defp process_message(nil), do: IO.puts "nil"
  defp process_message(%{update_id: id} = message) do
    App.Matcher.match message
    
    id
  end
end
