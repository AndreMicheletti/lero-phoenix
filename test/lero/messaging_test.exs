defmodule Lero.MessagingTest do
  use Lero.DataCase

  alias Lero.Messaging
  alias Lero.Accounts

  @sample_message %{"ct" => "123", "iv" => "asd", "salt" => "xyz"}

  describe "conversations" do
    alias Lero.Messaging.Conversation
    setup [:create_users]

    def conversation_fixture(attrs \\ %{}) do
      {:ok, conversation} = Messaging.create_conversation(attrs)
      conversation
    end

    test "start_conversation/2 with valid data creates a conversation" do
      user1 = Accounts.get_user_by_name("User 1")
      user2 = Accounts.get_user_by_name("User 2")
      assert {:ok, %Conversation{} = conversation} = Messaging.start_conversation(user1.id, user2.id)
    end

    test "start_conversation/2 with duplicate data doesn't create a conversation" do
      user1 = Accounts.get_user_by_name("User 1")
      user2 = Accounts.get_user_by_name("User 2")
      conversation = conversation_fixture(%{ title: "Conversation", participants: [user1.id, user2.id] })
      assert {:error, _} = Messaging.start_conversation(user1.id, user2.id)
      assert {:error, _} = Messaging.start_conversation(user2.id, user1.id)
    end

    test "find_conversation/2 with finds the correct conversation" do
      user1 = Accounts.get_user_by_name("User 1")
      user2 = Accounts.get_user_by_name("User 2")
      conversation = conversation_fixture(%{ title: "Conversation", participants: [user1.id, user2.id] })
      conversation1 = Messaging.find_or_start_conversation(user1.id, user2.id)
      conversation2 = Messaging.find_or_start_conversation(user2.id, user1.id)
      assert conversation.id == conversation1.id
      assert conversation.id == conversation2.id
      assert conversation1.id == conversation2.id
    end

    test "find_or_start_conversation/2 with valid data creates a conversation" do
      user1 = Accounts.get_user_by_name("User 1")
      user2 = Accounts.get_user_by_name("User 2")
      conversation = Messaging.find_or_start_conversation(user1.id, user2.id)
      assert conversation.id
    end

    test "find_or_start_conversation/2 with duplicate data doesn't create a conversation" do
      user1 = Accounts.get_user_by_name("User 1")
      user2 = Accounts.get_user_by_name("User 2")
      conversation = conversation_fixture(%{ title: "Conversation", participants: [user1.id, user2.id] })
      conversation1 = Messaging.find_or_start_conversation(user1.id, user2.id)
      conversation2 = Messaging.find_or_start_conversation(user2.id, user1.id)
      assert conversation.id == conversation1.id
      assert conversation.id == conversation2.id
      assert conversation1.id == conversation2.id
    end

    test "get_conversation_messages/1 returns a empty list" do
      user1 = Accounts.get_user_by_name("User 1")
      user2 = Accounts.get_user_by_name("User 2")
      conversation = conversation_fixture(%{ title: "Conversation", participants: [user1.id, user2.id] })

      assert Messaging.get_conversation_messages(conversation.id) == []
    end

    test "get_conversation_messages/1 returns a message list from sender and recipient" do
      user1 = Accounts.get_user_by_name("User 1")
      user2 = Accounts.get_user_by_name("User 2")
      conversation = conversation_fixture(%{ title: "Conversation", participants: [user1.id, user2.id] })

      Messaging.send_message(user1.id, conversation.id, @sample_message)  # message by sender
      Messaging.send_message(user2.id, conversation.id, @sample_message)  # message by recipient

      assert length(Messaging.get_conversation_messages(conversation.id)) == 2
    end
  end

  describe "messages" do
    alias Lero.Messaging.Message
    setup [:create_users]

    def message_fixture(attrs \\ %{}) do
      {:ok, message} = Messaging.create_message(attrs)
      message
    end

    def conversation_fixture_2(attrs \\ %{}) do
      user1 = Accounts.get_user_by_name("User 1")
      user2 = Accounts.get_user_by_name("User 2")
      {:ok, conversation} =
        attrs
          |> Enum.into(%{ title: nil, participants: [user1.id, user2.id]})
          |> Messaging.create_conversation()
      conversation
    end

    test "get_message!/1 by id works" do
      user1 = Accounts.get_user_by_name("User 1")
      conversation = conversation_fixture_2()
      message = message_fixture(%{ content: @sample_message, user_id: user1.id, conversation_id: conversation.id })
      fetched = Messaging.get_message!(message.id)
      assert message.id == fetched.id
      assert message.conversation_id == conversation.id
      assert message.user_id == user1.id
    end

    test "send_message_to/3 creates a new conversation" do
      user1 = Accounts.get_user_by_name("User 1")
      user2 = Accounts.get_user_by_name("User 2")
      assert Messaging.find_conversation(user1.id, user2.id) == nil

      {:ok, message} = Messaging.send_message_to(user1.id, user2.id, @sample_message)

      assert Messaging.find_conversation(user1.id, user2.id) != nil
      assert Messaging.find_conversation(user2.id, user1.id) != nil
      assert message.conversation_id == Messaging.find_conversation(user1.id, user2.id).id
    end

    test "send_message_to/3 uses a existing conversation" do
      user1 = Accounts.get_user_by_name("User 1")
      user2 = Accounts.get_user_by_name("User 2")
      conversation = conversation_fixture_2()

      {:ok, message} = Messaging.send_message_to(user1.id, user2.id, @sample_message)
      assert message.conversation_id == conversation.id
    end
  end

  defp create_users(_) do
    Accounts.create_user(%{name: "User 1", description: "hello world", secret_code: "mycode", password: "123"})
    Accounts.create_user(%{name: "User 2", description: "hello world", secret_code: "yoo", password: "123"})
    :ok
  end
end
