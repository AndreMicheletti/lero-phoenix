defmodule Lero.HttpErrorHandler do
  use LeroWeb, :controller

  def unauthenticated(conn, _params) do
    json(conn, %{ success: false, status: "unauthenticated" })
  end

  def unauthorized(conn, _params) do
    json(conn, %{ success: false, status: "unauthorized" })
  end

end
