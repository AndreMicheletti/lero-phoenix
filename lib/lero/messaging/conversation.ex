defmodule Lero.Messaging.Conversation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "conversations" do
    field :title, :string
    field :participants, {:array, :integer}

    has_many :messages, Lero.Messaging.Message

    timestamps()
  end

  @doc false
  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:title, :participants])
    |> validate_required([:participants])
  end
end
