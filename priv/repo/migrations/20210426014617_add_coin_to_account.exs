defmodule Lero.Repo.Migrations.AddCoinToAccount do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :coins, :integer, default: 0
    end
  end
end
