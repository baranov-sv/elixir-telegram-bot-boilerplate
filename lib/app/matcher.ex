defmodule App.Matcher do
  use GenServer
  alias App.Commands
  require Logger  

  # Server

  def start_link do
    Logger.log :info, "Started matcher"    
    GenServer.start_link __MODULE__, :ok, name: __MODULE__
  end

  def init(:ok) do
    {:ok, 0}
  end

  def handle_cast(message, state) do
    Commands.match_message message

    {:noreply, state}
  end

  # Client

  def match(message) do
    GenServer.cast __MODULE__, message
  end
end
