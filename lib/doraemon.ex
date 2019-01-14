defmodule Doraemon do
  use Nostrum.Consumer
  require Logger

  @ch_log 533365934354726922

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  # Handle command
  def handle_event({:MESSAGE_CREATE, {msg}, ws_state}) do
    Doraemon.Message.handle_create(msg)
  end

  # Send cleaning messages log in general channel to log channel
  def handle_event({:MESSAGE_DELETE_BULK, {updated_messages}, _ws_state}) do
    Doraemon.Message.handle_delete(updated_messages)
  end

  def handle_event(_noop) do
    Logger.info "noop"
  end
end
