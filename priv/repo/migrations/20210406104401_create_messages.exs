defmodule Lero.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :content, :string

      add :user_id, references(:users)
      add :conversation_id, references(:conversations)

      timestamps()
    end

  end
end
