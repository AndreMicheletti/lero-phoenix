defmodule LeroWeb.ConversationControllerTest do
  use LeroWeb.ConnCase

  alias Lero.Messaging

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  def fixture(:conversation) do
    {:ok, conversation} = Messaging.create_conversation(@create_attrs)
    conversation
  end

  describe "index" do
    test "lists all conversations", %{conn: conn} do
      conn = get(conn, Routes.conversation_path(conn, :index))
      assert json_response(conn, 200) == %{ "success" => true, "conversations" => [] }
    end
  end

  describe "create conversation" do
  end

  describe "edit conversation" do
  end

  describe "update conversation" do
  end

  describe "delete conversation" do
  end

  defp create_conversation(_) do
    conversation = fixture(:conversation)
    %{conversation: conversation}
  end
end
