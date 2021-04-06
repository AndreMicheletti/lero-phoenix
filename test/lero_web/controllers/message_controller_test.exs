defmodule LeroWeb.MessageControllerTest do
  use LeroWeb.ConnCase

  alias Lero.Messaging

  @create_attrs %{content: "some content"}
  @update_attrs %{content: "some updated content"}
  @invalid_attrs %{content: nil}

  def fixture(:message) do
    {:ok, message} = Messaging.create_message(@create_attrs)
    message
  end

  describe "index" do
    test "lists all messages", %{conn: conn} do
      conn = get(conn, Routes.message_path(conn, :index))
      assert json_response(conn, 200) == %{ "success" => true, "messages" => [] }
    end
  end

  describe "create message" do
  end

  describe "edit message" do
  end

  describe "update message" do
  end

  describe "delete message" do
  end

  defp create_message(_) do
    message = fixture(:message)
    %{message: message}
  end
end
