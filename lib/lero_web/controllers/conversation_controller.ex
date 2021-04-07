defmodule LeroWeb.ConversationController do
  use LeroWeb, :controller
  use Guardian.Phoenix.Controller

  alias Lero.Messaging
  alias Lero.Accounts

  def index(conn, _params, _user, _claims) do
    conversations = Messaging.list_conversations()
    json(conn, %{ success: true, conversations: conversations })
  end

  def create(conn, %{"user_name" => user_name, "target_user" => target_user}, _user, _claims) do
    user = Accounts.get_user_by_name(user_name)
    target = Accounts.get_user_by_name(target_user)

    case Messaging.create_conversation(%{user_id: user.id, target_id: target.id}) do
      {:ok, conversation} ->
        json(conn, %{ success: true, conversation: conversation })

      {:error, _} ->
        json(conn, %{ success: true, status: 'Error' })
    end
  end

  def show(conn, %{"id" => id}, _user, _claims) do
    conversation = Messaging.get_conversation!(id)
    json(conn, %{ success: true, conversation: conversation })
  end

  def edit(conn, %{"id" => id}, _user, _claims) do
    conversation = Messaging.get_conversation!(id)
    Messaging.change_conversation(conversation)
    json(conn, %{ success: true, conversation: conversation })
  end

  def update(conn, %{"id" => id, "conversation" => conversation_params}, _user, _claims) do
    conversation = Messaging.get_conversation!(id)

    case Messaging.update_conversation(conversation, conversation_params) do
      {:ok, conversation} ->
        json(conn, %{ success: true, conversation: conversation })

      {:error, _} ->
        json(conn, %{ success: true, status: 'Error' })
    end
  end

  def delete(conn, %{"id" => id}, _user, _claims) do
    conversation = Messaging.get_conversation!(id)
    {:ok, _conversation} = Messaging.delete_conversation(conversation)

    json(conn, %{ success: true, status: 'Deleted' })
  end
end
