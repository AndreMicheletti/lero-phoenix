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
        |> socket("user_id", %{current_user: user})
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
end
