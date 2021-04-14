defmodule Lero.Repo.Migrations.ChangeMessageContentToMap do
  use Ecto.Migration

  def change do
    execute "DELETE FROM messages;"
    execute "ALTER TABLE messages DROP content;"

    alter table(:messages) do
      add :content, :map
    end
  end
end
