defmodule Lero.Repo do
  use Ecto.Repo,
    otp_app: :lero,
    adapter: Ecto.Adapters.Postgres
end
