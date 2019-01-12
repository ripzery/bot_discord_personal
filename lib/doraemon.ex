defmodule Doraemon do
  use Nostrum.Consumer
  require Logger
  alias Nostrum.Api

  @ch_log 533365934354726922

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  defp get_message_ids(%Nostrum.Struct.Message{channel_id: channel_id}, limit \\ 100) do
    case Api.get_channel_messages(channel_id, limit) do
      {:ok, messages} -> messages |> Enum.map(fn(m) -> m.id end)
      _ -> :error
    end
  end

  def handle_event({:MESSAGE_CREATE, {msg}, ws_state}) do
    case msg.content do
      << ?p, ?l, ?a, ?y, ?\s, song :: binary >> -> 
        Api.create_message(msg.channel_id, "Play #{song} on spotify.")
        System.cmd("spotify", ["play", song]) 
        {:ok, %Giphy.Page{data: data}} = Giphy.search(song, limit: 1)
        %Giphy.GIF{images: %{"preview_gif" => %{"url" => url} }} = data |> Enum.at(0)
        Api.create_message(msg.channel_id, url)
        { lyric, _ } = System.cmd("lyrics", ["\"#{song}\""])
        debug song
        Api.create_message(msg.channel_id, "\`\`\`#{lyric}\`\`\`")
      << ?p, ?l, ?a, ?y, ?l, ?i, ?s, ?t, ?\s, playlist :: binary >> -> 
        Api.create_message(msg.channel_id, "Play playlist #{playlist} on spotify.")
        {output, _ } = System.cmd("spotify", ["play", "list", playlist]) 
        Api.create_message(msg.channel_id, output)
      "doraemon" -> Api.create_message(msg.channel_id, "Hey, master. What kind of fabulous idea you want me to serve?")
      "clear" -> 
        # Start shouting up...
        Api.create_message(msg.channel_id, "Cleaning up...")
        {status} = Api.bulk_delete_messages(msg.channel_id, get_message_ids(msg))
        print_status("Clear messages", status)
      << ?a, ?d, ?d, ?\s, something :: binary >> -> Api.create_message(msg.channel_id, "Adding #{something} to your task list...")
        
      "ping" -> Api.create_message(msg.channel_id, "pong!")
        _ -> :ignore
    end
  end

  def handle_event({:MESSAGE_DELETE_BULK, {updated_messages}, _ws_state}) do
    Api.create_message(@ch_log, "Finish cleaning up #{Enum.count(updated_messages.ids) - 1} messages.")
  end

  defp debug(var), do: Logger.info "#{inspect var}"

  defp print_status(action, status) do
    Logger.info "#{action}: #{status}"
  end

  def handle_event({:MESSAGE_CREATE, {msg}, ws_state}) do
    case msg.content do
      "ping" -> Api.create_message(msg.channel_id, "pong!")
        _ -> :ignore
    end
  end

  def handle_event(_noop) do
    Logger.info "noop"
  end
end
