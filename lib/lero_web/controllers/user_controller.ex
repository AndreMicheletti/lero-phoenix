defmodule LeroWeb.UserController do
  use LeroWeb, :controller

  alias Lero.Accounts


  def login(conn, %{"secret_code" => secret_code, "password" => plain_password}) do
    case Accounts.authenticate_user(secret_code, plain_password) do
      {:ok, user} ->
        {:ok, jwt, _claims} = Guardian.encode_and_sign(user, :access)
        json(conn, %{ success: true, token: jwt })
  
      {:error, reason} -> json(conn, %{ success: false, status: "invalid credentials" })
    end
  end

  def register(conn, %{"user" => user_params, "password" => plain_password}) do
    case Accounts.create_user(Map.merge(user_params, %{"password" => plain_password})) do
      {:ok, user} ->
        json(conn, %{ success: true, user: serialize_user(user) })

      {:error, _} ->
        json(conn, %{ success: false, status: 'Error' })
    end
  end

  def show(conn, _params) do
    if Guardian.Plug.authenticated?(conn) do
      user = Guardian.Plug.current_resource(conn)
      json(conn, %{ success: true, user: serialize_user(user) })
    else
      json(conn, %{ success: false, status: "unauthorized" })
    end
  end

  def update(conn, %{"user" => user_params}) do
    if Guardian.Plug.authenticated?(conn) do
      user = Guardian.Plug.current_resource(conn)
      case Accounts.update_user(user, user_params) do
        {:ok, user} ->
          json(conn, %{ success: true, user: serialize_user(user) })

        {:error, _} ->
          json(conn, %{ success: false, status: 'Error' })
      end
    else
      json(conn, %{ success: false, status: "unauthorized" })
    end
  end

  def delete(conn, %{"id" => id}, _user, _claims) do
  end

  def serialize_user(user) do
    %{ id: user.id, name: user.name, secret_code: user.secret_code, description: user.description }
  end
end
