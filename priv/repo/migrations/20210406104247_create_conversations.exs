defmodule Lero.Repo.Migrations.CreateConversations do
  use Ecto.Migration

  def change do
    create table(:conversations) do

      add :title, :string
      add :participants, {:array, :integer}

      timestamps()
    end
  end
end
