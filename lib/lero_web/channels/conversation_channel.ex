defmodule LeroWeb.ConversationChannel do
  use LeroWeb, :channel

  alias Lero.Accounts
  alias Lero.Messaging

  @impl true
  def join("conversation:" <> conversation_id, _params, socket) do
    # if authorized?(payload) do
    #   {:ok, socket}
    # else
    #   {:error, %{reason: "unauthorized"}}
    # end
    case socket do
      %Phoenix.Socket{assigns: %{current_user: current_user}} ->
        conversation = Messaging.get_conversation!(conversation_id)
        socket = assign(socket, :conversation, conversation)
        response  = %{conversation: serialize_conversation(conversation, current_user.id)}
        {:ok, response, socket}
      _ ->
        {:error, %{ success: false, }, socket}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (conversation:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def serialize_conversation(conversation, user_id) do
    if conversation.title do
      %{title: conversation.title }
    else
      %{title: Messaging.get_conversation_title_based_on_user(conversation, user_id) }
    end
  end
end
