defmodule LeroWeb.UserControllerTest do
  use LeroWeb.ConnCase

  alias Lero.Accounts

  @create_attrs %{name: "some name", description: "", secret_code: "123", password: "123"}
  @update_attrs %{name: "some updated name", description: "", secret_code: "123", password: "123"}
  @invalid_attrs %{name: nil, description: "", secret_code: "123", password: "123"}

  describe "authorized" do
    setup %{conn: conn} do
      {:ok, user} = Accounts.create_user(%{name: "Dummy User", description: "hello world", secret_code: "mycode", password: "123"})
      {:ok, jwt, _claims} = Guardian.encode_and_sign(user)
      conn =
        conn
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer #{jwt}")

      {:ok, conn: conn}
    end

    test "get own user", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :show))
      assert %{ "success" => true, "user" => json_user } = json_response(conn, 200)
      assert json_user["name"] == "Dummy User"
      assert json_user["secretCode"] == "mycode"
    end

    test "edit own user", %{conn: conn} do
      update_params = %{user: %{name: "some updated name", description: "some updated description"}}
      conn = post(conn, Routes.user_path(conn, :update, update_params))
      assert %{ "success" => true, "user" => json_user } = json_response(conn, 200)
      assert json_user["name"] == "some updated name"
      assert json_user["description"] == "some updated description"
      assert json_user["secretCode"] == "mycode"
    end

    test "edit own password", %{conn: conn} do
      old_password = Accounts.get_user_by_secret_code("mycode").hashed_password
      update_params = %{user: %{name: "some updated name", description: "some updated description", password: "something different"}}
      conn = post(conn, Routes.user_path(conn, :update, update_params))
      assert %{ "success" => true, "user" => json_user } = json_response(conn, 200)
      assert json_user["name"] == "some updated name"
      assert json_user["description"] == "some updated description"
      assert json_user["secretCode"] == "mycode"
      assert Accounts.get_user_by_secret_code("mycode").hashed_password != old_password
    end

    test "cannot edit own secret_code", %{conn: conn} do
      update_params = %{user: %{name: "some updated name", description: "some updated description", secret_code: "changedcode"}}
      conn = post(conn, Routes.user_path(conn, :update, update_params))
      assert %{ "success" => true, "user" => json_user } = json_response(conn, 200)
      assert json_user["name"] == "some updated name"
      assert json_user["description"] == "some updated description"
      assert json_user["secretCode"] == "mycode"  # should remain the same code
    end

    test "delete own user", %{conn: conn} do
      conn = delete(conn, Routes.user_path(conn, :delete))
      assert %{ "success" => true, "status" => "Deleted" } = json_response(conn, 200)
      assert is_nil(Accounts.get_user_by_name("Dummy User"))
    end
  end

  describe "register user" do
    test "with valid data", %{conn: conn} do
      params = %{name: "My User", description: "", secret_code: "123"}
      conn = post(conn, Routes.user_path(conn, :register, %{ user: params, password: "123" }))
      assert %{ "success" => true, "user" => json_user } = json_response(conn, 200)

      user = Accounts.get_user!(json_user["id"])
      assert user.id == json_user["id"]
      assert user.name == "My User"
      assert user.secret_code == "123"
      assert user.hashed_password != "123"
    end

    test "with invalid data", %{conn: conn} do
      params = %{name: nil, description: "", secret_code: "123"}
      conn = post(conn, Routes.user_path(conn, :register, %{ user: params, password: "123" }))
      assert %{ "success" => false, "status" => _ } = json_response(conn, 200)
    end

    test "with duplicated secret_code", %{conn: conn} do
      {:ok, user} = Accounts.create_user(@create_attrs)
      params = %{name: "My User", description: "", secret_code: user.secret_code}
      conn = post(conn, Routes.user_path(conn, :register, %{ user: params, password: "123" }))
      assert %{ "success" => false, "status" => _ } = json_response(conn, 200)
    end
  end
end
