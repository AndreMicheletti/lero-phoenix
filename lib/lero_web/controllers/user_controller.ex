defmodule LeroWeb.UserController do
  use LeroWeb, :controller

  alias Lero.Accounts

  def index(conn, _params) do
    users = Accounts.list_users()
    json(conn, %{ success: true, users: users })
  end

  def create(conn, %{"user" => user_params, "password" => plain_password}) do
    hashed_password = Bcrypt.hash_pwd_salt(plain_password)
    case Accounts.create_user(Map.merge(user_params, %{"hashed_password" => hashed_password})) do
      {:ok, user} ->
        json(conn, %{ success: true, user: %{ id: user.id, name: user.name, secret_code: user.secret_code, description: user.description } })

      {:error, _} ->
        json(conn, %{ success: false, status: 'Error' })
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    json(conn, %{ success: true, user: user })
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    Accounts.change_user(user)
    json(conn, %{ success: true, user: user })
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        json(conn, %{ success: true, user: user })

      {:error, _} ->
        json(conn, %{ success: false, status: 'Error' })
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    json(conn, %{ success: true, status: 'Deleted' })
  end
end
