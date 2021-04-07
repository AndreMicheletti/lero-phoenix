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
    messages =
      Messaging.get_conversation_messages(id)
      |> Enum.map(fn x -> serialize_message(x, user.id) end)
    json(conn, %{ success: true, messages: messages })
  end

  def serialize_conversation(conversation, user_id) do
    if conversation.title do
      %{title: conversation.title }
    else
      %{title: Messaging.get_conversation_title_based_on_user(conversation, user_id) }
    end
  end

  def serialize_message(message, user_id) do
    %{ content: message.content, direction: (if message.user_id == user_id, do: "out", else: "in") }
  end
end
