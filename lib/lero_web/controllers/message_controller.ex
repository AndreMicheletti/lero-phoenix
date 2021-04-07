defmodule LeroWeb.MessageController do
  use LeroWeb, :controller
  use Guardian.Phoenix.Controller

  alias Lero.Accounts
  alias Lero.Messaging

  def send(conn, %{"content" => content, "secret_code" => secret_code}, user, _claims) do

    target = Accounts.get_user_by_secret_code(secret_code)

    if is_nil(target) do
      json(conn, %{ success: false, status: "target not found" })
    else
      {:ok, message} = Messaging.send_message_to(user.id, target.id, content)
      json(conn, %{ success: true, message: serialize_message(message) })
    end
  end

  def serialize_message(message) do
    %{ id: message.id, content: message.content, conversation_id: message.conversation_id, time: message.inserted_at }
  end
end
