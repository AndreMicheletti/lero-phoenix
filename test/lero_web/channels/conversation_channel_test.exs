defmodule LeroWeb.ConversationChannelTest do
  use LeroWeb.ChannelCase

  alias Lero.Accounts
  alias Lero.Messaging

  describe "authorized user" do
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

    test "ping replies with status ok", %{socket: socket} do
      ref = push socket, "ping", %{"hello" => "there"}
      assert_reply ref, :ok, %{"hello" => "there"}
    end

    test "shout broadcasts to conversation:lobby", %{socket: socket} do
      push socket, "shout", %{"hello" => "all"}
      assert_broadcast "shout", %{"hello" => "all"}
    end

    test "broadcasts are pushed to the client", %{socket: socket} do
      broadcast_from! socket, "broadcast", %{"some" => "data"}
      assert_push "broadcast", %{"some" => "data"}
    end
  end
end
