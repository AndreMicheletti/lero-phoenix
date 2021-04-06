defmodule LeroWeb.UserControllerTest do
  use LeroWeb.ConnCase

  alias Lero.Accounts

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert json_response(conn, 200) == %{ "success" => true, "users" => [] }
    end
  end

  describe "create user" do
  end

  describe "edit user" do
  end

  describe "update user" do
  end

  describe "delete user" do
  end

  defp create_user(_) do
    user = fixture(:user)
    %{user: user}
  end
end
