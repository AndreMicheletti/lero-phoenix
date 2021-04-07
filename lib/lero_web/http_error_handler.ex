defmodule Lero.HttpErrorHandler do
  use LeroWeb, :controller

  def unauthenticated(conn, _params) do
    conn |> json %{ success: false, status: "unauthenticated" }
  end

  def unauthorized(conn, _params) do
    conn |> json %{ success: false, status: "unauthorized" }
  end

end