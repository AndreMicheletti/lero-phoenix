defmodule LeroWeb.ConversationController do
  use LeroWeb, :controller

  alias Lero.Messaging

  def index(conn, _params) do
    conversations = Messaging.list_conversations()
    json(conn, %{ success: true, conversations: conversations })
  end

  def create(conn, %{"conversation" => conversation_params}) do
    case Messaging.create_conversation(conversation_params) do
      {:ok, conversation} ->
        json(conn, %{ success: true, conversation: conversation })

      {:error, _} ->
        json(conn, %{ success: true, status: 'Error' })
    end
  end

  def show(conn, %{"id" => id}) do
    conversation = Messaging.get_conversation!(id)
    json(conn, %{ success: true, conversation: conversation })
  end

  def edit(conn, %{"id" => id}) do
    conversation = Messaging.get_conversation!(id)
    Messaging.change_conversation(conversation)
    json(conn, %{ success: true, conversation: conversation })
  end

  def update(conn, %{"id" => id, "conversation" => conversation_params}) do
    conversation = Messaging.get_conversation!(id)

    case Messaging.update_conversation(conversation, conversation_params) do
      {:ok, conversation} ->
        json(conn, %{ success: true, conversation: conversation })

      {:error, _} ->
        json(conn, %{ success: true, status: 'Error' })
    end
  end

  def delete(conn, %{"id" => id}) do
    conversation = Messaging.get_conversation!(id)
    {:ok, _conversation} = Messaging.delete_conversation(conversation)

    json(conn, %{ success: true, status: 'Deleted' })
  end
end
