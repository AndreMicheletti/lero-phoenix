defmodule LeroWeb.MessageControllerTest do
  use LeroWeb.ConnCase

  alias Lero.Messaging
  alias Lero.Messaging.Conversation
  alias Lero.Accounts

  @create_attrs %{content: "some content"}
  @update_attrs %{content: "some updated content"}
  @invalid_attrs %{content: nil}

  def fixture(:message) do
    {:ok, message} = Messaging.create_message(@create_attrs)
    message
  end

  describe "authorized" do
    setup %{conn: conn} do
      {:ok, user} = Accounts.create_user(%{name: "Dummy User", description: "hello world", secret_code: "mycode", password: "123"})
      {:ok, jwt, _claims} = Guardian.encode_and_sign(user)
      conn =
        conn
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer #{jwt}")

      Accounts.create_user(%{name: "User 2", description: "hello world", secret_code: "yoo", password: "123"})
      Accounts.create_user(%{name: "User 3", description: "hello world", secret_code: "yoo3", password: "123"})

      {:ok, conn: conn}
    end

    def conversation_fixture(attrs \\ %{}) do
      user1 = Accounts.get_user_by_name("Dummy User")
      user2 = Accounts.get_user_by_name("User 2")
      {:ok, conversation} =
        attrs
          |> Enum.into(%{ title: nil, participants: [user1.id, user2.id]})
          |> Messaging.create_conversation()
      conversation
    end

    def conversation_with_messages_fixture(out_messages_len, in_messages_len) do
      user = Accounts.get_user_by_name("Dummy User")
      user2 = Accounts.get_user_by_name("User 2")
      conversation = conversation_fixture()
      Enum.each(1..out_messages_len, fn(x) ->
        Messaging.send_message(user.id, conversation.id, "hello")
      end)
      Enum.each(1..in_messages_len, fn(x) ->
        Messaging.send_message(user2.id, conversation.id, "hello")
      end)
      conversation
    end

    test "get conversation messages with direction", %{conn: conn} do
      conversation = conversation_with_messages_fixture(2, 4)
      conn = get(conn, Routes.conversation_path(conn, :details, conversation.id))

      assert %{ "success" => true, "messages" => messages } = json_response(conn, 200)
      assert length(messages) == 6
      assert (Enum.slice(messages, 0, 2) |> Enum.all?(fn x -> x["direction"] == "out" end)) == true
      assert (Enum.slice(messages, 2, 4) |> Enum.all?(fn x -> x["direction"] == "in" end)) == true
    end
  end

  describe "unauthorized" do
  end

  defp create_message(_) do
    message = fixture(:message)
    %{message: message}
  end
end
