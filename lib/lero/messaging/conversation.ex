defmodule Lero.Messaging.Conversation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "conversations" do
    field :target_id, :integer
    belongs_to :user, Lero.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:user_id, :target_id])
    |> validate_required([:user_id, :target_id])
  end
end
