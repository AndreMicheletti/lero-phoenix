defmodule LeroWeb.MessageController do
  use LeroWeb, :controller
  use Guardian.Phoenix.Controller

  alias Lero.Messaging

  def index(conn, _params, _user, _claims) do
    messages = Messaging.list_messages()
    json(conn, %{ success: true, messages: messages })
  end

  def create(conn, %{"message" => message_params}, _user, _claims) do
    case Messaging.create_message(message_params) do
      {:ok, message} ->
        json(conn, %{ success: true, message: message })

      {:error, _} ->
        json(conn, %{ success: true, status: 'Error' })
    end
  end

  def show(conn, %{"id" => id}, _user, _claims) do
    message = Messaging.get_message!(id)
    json(conn, %{ success: true, message: message })
  end

  def edit(conn, %{"id" => id}, _user, _claims) do
    message = Messaging.get_message!(id)
    Messaging.change_message(message)
    json(conn, %{ success: true, message: message })
  end

  def update(conn, %{"id" => id, "message" => message_params}, _user, _claims) do
    message = Messaging.get_message!(id)

    case Messaging.update_message(message, message_params) do
      {:ok, message} ->
        json(conn, %{ success: true, message: message })

      {:error, _} ->
        json(conn, %{ success: true, status: 'Error' })
    end
  end

  def delete(conn, %{"id" => id}, _user, _claims) do
    message = Messaging.get_message!(id)
    {:ok, _message} = Messaging.delete_message(message)
    json(conn, %{ success: true, status: 'Deleted' })
  end
end
