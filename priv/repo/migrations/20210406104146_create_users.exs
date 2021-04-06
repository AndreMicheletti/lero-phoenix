defmodule Lero.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :description, :string
      add :secret_code, :string
      add :hashed_password, :string

      timestamps()
    end

    create unique_index(:users, [:secret_code])
  end
end
