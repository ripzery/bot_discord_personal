defmodule Doraemon.Message do
  alias Nostrum.Api
  require Logger
  @ch_log 533365934354726922

  def handle_create(%Nostrum.Struct.Message{content: << "play ", song :: binary >>} = msg) do
    Api.create_message(msg.channel_id, "Play #{song} on spotify.")
    System.cmd("spotify", ["play", song]) 
    {:ok, %Giphy.Page{data: data}} = Giphy.search(song, limit: 1)
    %Giphy.GIF{images: %{"preview_gif" => %{"url" => url} }} = data |> Enum.at(0)
    Api.create_message(msg.channel_id, url)
    { lyric, _ } = System.cmd("lyrics", ["\"#{song}\""])
    debug song
    Api.create_message(msg.channel_id, "\`\`\`#{lyric}\`\`\`")
  end

  def handle_create(%Nostrum.Struct.Message{content: << "playlist ", playlist :: binary >>} = msg) do
    Api.create_message(msg.channel_id, "Play playlist #{playlist} on spotify.")
    {output, _ } = System.cmd("spotify", ["play", "list", playlist]) 
    Api.create_message(msg.channel_id, output)
  end

  def handle_create(%Nostrum.Struct.Message{content: << "add ", task :: binary >>} = msg) do
    Api.create_message(msg.channel_id, "Adding #{task} to your task list...")
  end

  def handle_create(%Nostrum.Struct.Message{content: "doraemon"} = msg) do
    Api.create_message(msg.channel_id, "Hey, master. What kind of fabulous idea you want me to serve?")
  end

  def handle_create(%Nostrum.Struct.Message{content: "clear"} = msg) do
     # Start shouting up...
     Api.create_message(msg.channel_id, "Cleaning up...")
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
