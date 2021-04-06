defmodule Lero.Repo.Migrations.CreateConversations do
  use Ecto.Migration

  def change do
    create table(:conversations) do

      add :user_id, references(:users)
      add :target_id, references(:users)

      timestamps()
    end

  end
end
