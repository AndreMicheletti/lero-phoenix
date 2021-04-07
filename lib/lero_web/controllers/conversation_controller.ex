defmodule LeroWeb.ConversationController do
  use LeroWeb, :controller
  use Guardian.Phoenix.Controller

  alias Lero.Messaging
  alias Lero.Accounts

  def index(conn, _params, user, _claims) do
    conversations = Accounts.get_user_conversations(user.id)
    json(conn, %{ success: true, conversations: Enum.map(conversations, fn x -> serialize_conversation(x, user.id) end) })
  end

  def serialize_conversation(conversation, user_id) do
    if conversation.title do
      %{title: conversation.title }
    else
      %{title: Messaging.get_conversation_title_based_on_user(conversation, user_id) }
    end
  end
end
