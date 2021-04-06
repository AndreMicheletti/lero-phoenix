defmodule LeroWeb.UserControllerTest do
  use LeroWeb.ConnCase

  alias Lero.Accounts

  @create_attrs %{name: "some name", description: "", secret_code: "123", hashed_password: "123"}
  @update_attrs %{name: "some updated name", description: "", secret_code: "123", hashed_password: "123"}
  @invalid_attrs %{name: nil, description: "", secret_code: "123", hashed_password: "123"}

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert json_response(conn, 200) == %{ "success" => true, "users" => [] }
    end
  end

  describe "register user" do
    test "with valid data", %{conn: conn} do
      params = %{name: "My User", description: "", secret_code: "123"}
      conn = post(conn, Routes.user_path(conn, :index, %{ user: params, password: "123" }))
      assert %{ "success" => true, "user" => json_user } = json_response(conn, 200)

      user = Accounts.get_user!(json_user["id"])
      assert user.id == json_user["id"]
      assert user.name == "My User"
      assert user.secret_code == "123"
      assert user.hashed_password != "123"
    end

    test "with invalid data", %{conn: conn} do
      params = %{name: nil, description: "", secret_code: "123"}
      conn = post(conn, Routes.user_path(conn, :index, %{ user: params, password: "123" }))
      assert %{ "success" => false, "status" => _ } = json_response(conn, 200)
    end

    test "with duplicated data", %{conn: conn} do
      {:ok, user} = Accounts.create_user(@create_attrs)
      params = %{name: "My User", description: "", secret_code: user.secret_code}
      conn = post(conn, Routes.user_path(conn, :index, %{ user: params, password: "123" }))
      assert %{ "success" => false, "status" => _ } = json_response(conn, 200)
    end
  end

  describe "edit user" do
  end

  describe "update user" do
  end

  describe "delete user" do
  end
end
