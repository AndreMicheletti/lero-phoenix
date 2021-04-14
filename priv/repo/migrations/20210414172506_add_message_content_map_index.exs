defmodule Lero.Repo.Migrations.AddMessageContentMapIndex do
  use Ecto.Migration

  def up do
    execute("CREATE INDEX index_message_content_gin ON messages USING GIN(content)")
  end

  def down do
    execute("DROP INDEX index_message_content_gin")
  end
end
