defmodule Doraemon.Message do
  alias Nostrum.Api
  require Logger
  @ch_log 533365934354726922

  def handle_create(%Nostrum.Struct.Message{content: << "play ", song :: binary >>} = msg) do
    send(%{msg | content: "Play #{song} on spotify."})
    System.cmd("spotify", ["play", song]) 
    {:ok, %Giphy.Page{data: data}} = Giphy.search(song, limit: 1)
    %Giphy.GIF{images: %{"preview_gif" => %{"url" => url} }} = data |> Enum.at(0)
    send(%{msg | content: url})
    { lyric, _ } = System.cmd("lyrics", ["\"#{song}\""])
    send(%{msg | content: "\`\`\`#{lyric}\`\`\`"})
  end

  def handle_create(%Nostrum.Struct.Message{content: << "playlist ", playlist :: binary >>} = msg) do
    send(%{msg | content: "Play playlist #{playlist} on spotify."})
    {output, _ } = System.cmd("spotify", ["play", "list", playlist]) 
    send(%{msg | content: output})
  end

  def handle_create(%Nostrum.Struct.Message{content: << "add ", task :: binary >>} = msg) do
    send(%{msg | content: "Adding #{task} to your task list..."})
  end

  def handle_create(%Nostrum.Struct.Message{content: "doraemon"} = msg) do
    send(%{msg | content: "Hey, master. What kind of fabulous idea you want me to serve?"})
  end

  def handle_create(%Nostrum.Struct.Message{content: "clear"} = msg) do
     # Start shouting up...
     send(%{msg | content: "Cleaning up..."})
     {status} = Api.bulk_delete_messages(msg.channel_id, get_message_ids(msg))
     print_status("Clear messages", status)
  end

  # Send cleaning messages log in general channel to log channel
  def handle_delete(updated_messages) do
    Api.create_message(@ch_log, "Finish cleaning up #{Enum.count(updated_messages.ids) - 1} messages.")
  end

  def handle_create(_) do
    :ignore
  end

  defp send(msg) do
    Api.create_message(msg.channel_id, msg.content)
  end

  # Convert messages list into message_ids list
  defp get_message_ids(%Nostrum.Struct.Message{channel_id: channel_id}, limit \\ 100) do
    case Api.get_channel_messages(channel_id, limit) do
      {:ok, messages} -> messages |> Enum.map(fn(m) -> m.id end)
      _ -> :error
    end
  end

  defp debug(var), do: Logger.info "#{inspect var}"

  defp print_status(action, status) do
    Logger.info "#{action}: #{status}"
  end
end
