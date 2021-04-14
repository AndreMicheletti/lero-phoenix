defmodule LeroWeb.ConversationControllerTest do
  use LeroWeb.ConnCase

  alias Lero.Messaging
  alias Lero.Accounts

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  def fixture(:conversation) do
    {:ok, conversation} = Messaging.create_conversation(@create_attrs)
    conversation
  end

  describe "unauthorized" do
    test "get conversations", %{conn: conn} do
      conn = get(conn, Routes.conversation_path(conn, :index))
      assert %{ "success" => false, "status" => "unauthenticated" } = json_response(conn, 200)
    end
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

    test "get empty conversations", %{conn: conn} do
      conn = get(conn, Routes.conversation_path(conn, :index))
      assert %{ "success" => true, "conversations" => conversations } = json_response(conn, 200)
      assert length(conversations) == 0
    end

    test "get conversations", %{conn: conn} do
      conversation_fixture()
      conn = get(conn, Routes.conversation_path(conn, :index))
      assert %{ "success" => true, "conversations" => conversations } = json_response(conn, 200)
      assert length(conversations) == 1
    end

    test "get conversations should return recipient name as title", %{conn: conn} do
      conversation_fixture()
      conn = get(conn, Routes.conversation_path(conn, :index))
      assert %{ "success" => true, "conversations" => conversations } = json_response(conn, 200)
      assert length(conversations) == 1
      assert Enum.at(conversations, 0)["title"] == "User 2"
    end
  end
end
