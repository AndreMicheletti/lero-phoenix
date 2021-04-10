defmodule LeroWeb.ConversationChannel do
  use LeroWeb, :channel

  alias Lero.Messaging

  @impl true
  def join("conversation:" <> conversation_id, _params, %Phoenix.Socket{assigns: assigns} = socket) do
    case assigns do
       %{ current_user: current_user } ->
          conversation = Messaging.get_conversation!(conversation_id)
          socket = assign(socket, :conversation, conversation)
          response  = %{ success: true, conversation: serialize_conversation(conversation, current_user.id)}
          {:ok, response, socket}
        _ ->
          {:error, %{ success: false }, socket}
    end
  end

  @impl true
  def handle_in("send_message", %{"content" => content}, %Phoenix.Socket{assigns: assigns} = socket) do
    case assigns do
      %{ current_user: user, conversation: conversation } ->
        {:ok, message} = Messaging.send_message(user.id, conversation.id, content)
        broadcast socket, "new_message", %{ message: serialize_message(message) }
        {:reply, {:ok, %{ message_id: message.id }}, socket}
      _ ->
        {:reply, {:error, %{}}, socket}
    end
  end

  def serialize_message(message) do
    %{ id: message.id, user_id: message.user_id, content: message.content, conversation_id: message.conversation_id, time: message.inserted_at }
  end

  def serialize_conversation(conversation, user_id) do
    if conversation.title do
      %{title: conversation.title }
    else
      %{title: Messaging.get_conversation_title_based_on_user(conversation, user_id) }
    end
  end
end
