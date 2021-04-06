defmodule Lero.MessagingTest do
  use Lero.DataCase

  alias Lero.Messaging
  alias Lero.Accounts

  describe "conversations" do
    alias Lero.Messaging.Conversation
    setup [:create_users]

    def conversation_fixture(attrs \\ %{}) do
      {:ok, conversation} = Messaging.create_conversation(attrs)
      conversation
    end

    test "start_conversation/1 with valid data creates a conversation" do
      user1 = Accounts.get_user_by_name("User 1")
      user2 = Accounts.get_user_by_name("User 2")
      assert {:ok, %Conversation{} = conversation} = Messaging.start_conversation(user1.id, user2.id)
    end

    test "start_conversation/1 with duplicate data doesn't create a conversation" do
      user1 = Accounts.get_user_by_name("User 1")
      user2 = Accounts.get_user_by_name("User 2")
      conversation = conversation_fixture(%{ title: "Conversation", participants: [user1.id, user2.id] })
      assert {:error, _} = Messaging.start_conversation(user1.id, user2.id)
      assert {:error, _} = Messaging.start_conversation(user2.id, user1.id)
    end
  end

  describe "messages" do
    alias Lero.Messaging.Message
    setup [:create_users]

    def message_fixture(attrs \\ %{}) do
      {:ok, message} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Messaging.create_message()

      message
    end
  end

  defp create_users(_) do
    user1 = Accounts.create_user(%{name: "User 1", description: "hello world", secret_code: "mycode"})
    user2 = Accounts.create_user(%{name: "User 2", description: "hello world", secret_code: "yoo"})
    :ok
  end
end
