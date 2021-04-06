defmodule Lero.MessagingTest do
  use Lero.DataCase

  alias Lero.Messaging
  alias Lero.Accounts

  describe "conversations" do
    alias Lero.Messaging.Conversation
    setup [:create_users]

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{user_id: 'a', target_id: 'a'}

    def conversation_fixture(attrs \\ %{}) do
      {:ok, conversation} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Messaging.create_conversation()

      conversation
    end

    test "list_conversations/0 returns all conversations" do
      user1 = Accounts.get_user_by_name("User 1")
      user2 = Accounts.get_user_by_name("User 2")
      conversation = conversation_fixture(%{ user_id: user1.id, target_id: user2.id })
      assert Messaging.list_conversations() == [conversation]
    end

    test "get_conversation!/1 returns the conversation with given id" do
      user1 = Accounts.get_user_by_name("User 1")
      user2 = Accounts.get_user_by_name("User 2")
      conversation = conversation_fixture(%{ user_id: user1.id, target_id: user2.id })
      assert Messaging.get_conversation!(conversation.id) == conversation
    end

    test "create_conversation/1 with valid data creates a conversation" do
      user1 = Accounts.get_user_by_name("User 1")
      user2 = Accounts.get_user_by_name("User 2")
      assert {:ok, %Conversation{} = conversation} = Messaging.create_conversation(%{ user_id: user1.id, target_id: user2.id })
    end

    test "create_conversation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Messaging.create_conversation(@invalid_attrs)
    end

    test "update_conversation/2 with valid data updates the conversation" do
      user1 = Accounts.get_user_by_name("User 1")
      user2 = Accounts.get_user_by_name("User 2")
      conversation = conversation_fixture(%{ user_id: user1.id, target_id: user2.id })
      assert {:ok, %Conversation{} = conversation} = Messaging.update_conversation(conversation, %{ user_id: user2.id, target_id: user1.id })
    end

    test "update_conversation/2 with invalid data returns error changeset" do
      user1 = Accounts.get_user_by_name("User 1")
      user2 = Accounts.get_user_by_name("User 2")
      conversation = conversation_fixture(%{ user_id: user1.id, target_id: user2.id })
      assert {:error, %Ecto.Changeset{}} = Messaging.update_conversation(conversation, @invalid_attrs)
      assert conversation == Messaging.get_conversation!(conversation.id)
    end

    test "delete_conversation/1 deletes the conversation" do
      user1 = Accounts.get_user_by_name("User 1")
      user2 = Accounts.get_user_by_name("User 2")
      conversation = conversation_fixture(%{ user_id: user1.id, target_id: user2.id })
      assert {:ok, %Conversation{}} = Messaging.delete_conversation(conversation)
      assert_raise Ecto.NoResultsError, fn -> Messaging.get_conversation!(conversation.id) end
    end

    test "change_conversation/1 returns a conversation changeset" do
      user1 = Accounts.get_user_by_name("User 1")
      user2 = Accounts.get_user_by_name("User 2")
      conversation = conversation_fixture(%{ user_id: user1.id, target_id: user2.id })
      assert %Ecto.Changeset{} = Messaging.change_conversation(conversation)
    end
  end

  describe "messages" do
    alias Lero.Messaging.Message
    setup [:create_users]

    @valid_attrs %{content: "some content"}
    @update_attrs %{content: "some updated content"}
    @invalid_attrs %{content: nil}

    def message_fixture(attrs \\ %{}) do
      {:ok, message} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Messaging.create_message()

      message
    end

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Messaging.list_messages() == [message]
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Messaging.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      assert {:ok, %Message{} = message} = Messaging.create_message(@valid_attrs)
      assert message.content == "some content"
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Messaging.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      assert {:ok, %Message{} = message} = Messaging.update_message(message, @update_attrs)
      assert message.content == "some updated content"
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Messaging.update_message(message, @invalid_attrs)
      assert message == Messaging.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Messaging.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Messaging.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Messaging.change_message(message)
    end
  end

  defp create_users(_) do
    user1 = Accounts.create_user(%{name: "User 1"})
    user2 = Accounts.create_user(%{name: "User 2"})
    :ok
  end
end
