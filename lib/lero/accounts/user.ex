defmodule Lero.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :description, :string
    field :secret_code, :string

    has_many :messages, Lero.Messaging.Message

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :description, :secret_code])
    |> validate_required([:name, :description, :secret_code])
    |> unique_constraint([:secret_code])
  end
end
