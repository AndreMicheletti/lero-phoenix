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
