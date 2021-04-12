defmodule LeroWeb.ConversationController do
  use LeroWeb, :controller
  use Guardian.Phoenix.Controller

  alias Lero.Messaging
  alias Lero.Accounts

  def index(conn, _params, user, _claims) do
    conversations =
      Accounts.get_user_conversations(user.id)
      |> Enum.map(fn x -> Messaging.serialize_conversation(x, user.id) end)
    json(conn, %{ success: true, conversations: conversations })
  end

  def details(conn, %{"id" => id}, user, _claims) do
    conversation = Messaging.get_conversation!(id)
    messages = Messaging.get_conversation_messages(id) |> Enum.map(fn x -> Messaging.serialize_message(x, user.id) end)
    json(conn, %{ success: true, conversation: Messaging.serialize_conversation(conversation, user.id), messages: messages })
  end
end
