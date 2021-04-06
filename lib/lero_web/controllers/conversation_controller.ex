defmodule LeroWeb.ConversationController do
  use LeroWeb, :controller

  alias Lero.Messaging
  alias Lero.Messaging.Conversation

  def index(conn, _params) do
    conversations = Messaging.list_conversations()
    render(conn, "index.html", conversations: conversations)
  end

  def new(conn, _params) do
    changeset = Messaging.change_conversation(%Conversation{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"conversation" => conversation_params}) do
    case Messaging.create_conversation(conversation_params) do
      {:ok, conversation} ->
        conn
        |> put_flash(:info, "Conversation created successfully.")
        |> redirect(to: Routes.conversation_path(conn, :show, conversation))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    conversation = Messaging.get_conversation!(id)
    render(conn, "show.html", conversation: conversation)
  end

  def edit(conn, %{"id" => id}) do
    conversation = Messaging.get_conversation!(id)
    changeset = Messaging.change_conversation(conversation)
    render(conn, "edit.html", conversation: conversation, changeset: changeset)
  end

  def update(conn, %{"id" => id, "conversation" => conversation_params}) do
    conversation = Messaging.get_conversation!(id)

    case Messaging.update_conversation(conversation, conversation_params) do
      {:ok, conversation} ->
        conn
        |> put_flash(:info, "Conversation updated successfully.")
        |> redirect(to: Routes.conversation_path(conn, :show, conversation))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", conversation: conversation, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    conversation = Messaging.get_conversation!(id)
    {:ok, _conversation} = Messaging.delete_conversation(conversation)

    conn
    |> put_flash(:info, "Conversation deleted successfully.")
    |> redirect(to: Routes.conversation_path(conn, :index))
  end
end
