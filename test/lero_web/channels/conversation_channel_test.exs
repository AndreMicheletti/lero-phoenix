defmodule LeroWeb.ConversationChannelTest do
  use LeroWeb.ChannelCase

  alias Lero.Accounts
  alias Lero.Messaging

  describe "channel conversation:id" do
    setup do
      {:ok, user2} = Accounts.create_user(%{name: "User 2", description: "hello world", secret_code: "yoo", password: "123"})
      {:ok, user3} = Accounts.create_user(%{name: "User 3", description: "hello world", secret_code: "yoo3", password: "123"})

      {:ok, user} = Accounts.create_user(%{name: "Dummy User", description: "hello world", secret_code: "mycode", password: "123"})
      {:ok, jwt, _claims} = Guardian.encode_and_sign(user)

      conversation = Messaging.find_or_start_conversation(user.id, user2.id)

      {:ok, _, socket} =
        LeroWeb.UserSocket
        |> socket("socket", %{current_user: user})
        |> subscribe_and_join(LeroWeb.ConversationChannel, "conversation:#{conversation.id}")

      %{socket: socket}
    end

    test "send_message replies with status ok and broadcasts 'new_message'", %{socket: socket} do
      ref = push socket, "send_message", %{"content" => "hello"}
      assert_reply ref, :ok, %{message_id: message_id}
      assert message_id

      message = Messaging.get_message!(message_id)
      assert message.user_id == socket.assigns.current_user.id

      assert_broadcast "new_message", %{message: serialized_message}
      assert serialized_message.id == message.id
      assert serialized_message.conversation_id == message.conversation_id
      assert serialized_message.user_id == message.user_id
      assert Map.has_key?(serialized_message, :time)
    end
  end

  describe "channel conversation:lobby" do
    setup do
      {:ok, user2} = Accounts.create_user(%{name: "User 2", description: "hello world", secret_code: "yoo", password: "123"})
      {:ok, user3} = Accounts.create_user(%{name: "User 3", description: "hello world", secret_code: "yoo3", password: "123"})

      {:ok, user} = Accounts.create_user(%{name: "Dummy User", description: "hello world", secret_code: "mycode", password: "123"})
      {:ok, jwt, _claims} = Guardian.encode_and_sign(user)

      {:ok, _, socket} =
        LeroWeb.UserSocket
        |> socket("socket", %{current_user: user})
        |> subscribe_and_join(LeroWeb.ConversationChannel, "conversation:lobby")

      %{socket: socket, me: user, other: user2}
    end

    test "receive broadcast `new_conversation` when conversation is created", %{socket: socket, me: user, other: user2} do
      conversation = Messaging.find_or_start_conversation(user.id, user2.id)

      assert_broadcast "new_conversation", %{ conversation: payload }, 100
      assert payload.id == conversation.id
      assert payload.title == user2.name
    end

    test "receive broadcast `upd_conversation` when message is sent to conversation", %{socket: socket, me: user, other: user2} do
      conversation = Messaging.find_or_start_conversation(user.id, user2.id)

      assert_broadcast "new_conversation", %{ conversation: payload }, 100

      Messaging.send_message(user.id, conversation.id, "hello world")

      assert_broadcast "upd_conversation", _payload, 100
      assert payload.id == conversation.id
      assert payload.title == user2.name
    end
  end
end
