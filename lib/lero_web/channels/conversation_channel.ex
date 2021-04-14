defmodule LeroWeb.ConversationChannel do
  use LeroWeb, :channel

  alias Lero.Messaging

  intercept ["upd_conversation", "new_conversation"]

  @impl true
  def join("conversation:lobby", _params, socket) do
    case socket.assigns do
       %{ current_user: _current_user } ->
          {:ok, %{ success: true }, socket}
        _ ->
          {:error, %{ success: false }, socket}
    end
  end

  @impl true
  def join("conversation:" <> conversation_id, _params, socket) do
    case socket.assigns do
       %{ current_user: current_user } ->
          conversation = Messaging.get_conversation!(conversation_id)
          socket = assign(socket, :conversation, conversation)
          response = %{ success: true, conversation: Messaging.serialize_conversation(conversation, current_user.id)}
          {:ok, response, socket}
        _ ->
          {:error, %{ success: false }, socket}
    end
  end

  @impl true
  def handle_in("send_message", %{"content" => content}, socket) do
    case socket.assigns do
      %{ current_user: user, conversation: conversation } ->
        {:ok, message} = Messaging.send_message(user.id, conversation.id, content)
        broadcast socket, "new_message", %{ message: Messaging.serialize_message(message) }
        {:reply, {:ok, %{ message_id: message.id }}, socket}
      _ ->
        {:reply, {:error, %{}}, socket}
    end
  end

  @impl true
  def handle_out("new_conversation", %{conversation: serialized_convs} = payload, socket) do
    if (serialized_convs.userId == socket.assigns.current_user.id) do
      push socket, "new_conversation", payload
    end
    {:noreply, socket}
  end

  @impl true
  def handle_out("upd_conversation", %{conversation: serialized_convs} = payload, socket) do
    if (serialized_convs.userId == socket.assigns.current_user.id) do
      push socket, "upd_conversation", payload
    end
    {:noreply, socket}
  end
end
