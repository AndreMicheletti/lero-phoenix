defmodule LeroWeb.ConversationController do
  use LeroWeb, :controller
  use Guardian.Phoenix.Controller

  alias Lero.Messaging
  alias Lero.Accounts

  def index(conn, _params, user, _claims) do
    conversations =
      Accounts.get_user_conversations(user.id)
      |> Enum.map(fn x -> serialize_conversation(x, user.id) end)
    json(conn, %{ success: true, conversations: conversations })
  end

  def details(conn, %{"id" => id}, user, _claims) do
    conversation = Messaging.get_conversation!(id)
    messages = Messaging.get_conversation_messages(id) |> Enum.map(fn x -> serialize_message(x, user.id) end)
    json(conn, %{ success: true, conversation: serialize_conversation(conversation, user.id), messages: messages })
  end

  def serialize_conversation(conversation, user_id) do
    title = if conversation.title, do: conversation.title, else: Messaging.get_conversation_title_based_on_user(conversation, user_id)
    %{
      id: conversation.id,
      title: title,
      participants:
        conversation.participants
          |> Enum.reject(fn x -> x == user_id end)
          |> Enum.map(fn x -> serialize_user(x) end)
    }
  end

  def serialize_message(message, user_id) do
    %{
      id: message.id,
      content: message.content,
      direction: (if message.user_id == user_id, do: "out", else: "in"),
      time: message.inserted_at
    }
  end

  def serialize_user(user_id) do
    user = Accounts.get_user!(user_id)
    %{ id: user.id, name: user.name, secretCode: user.secret_code }
  end
end
