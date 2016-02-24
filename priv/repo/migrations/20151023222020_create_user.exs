defmodule Saints.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :username, :string, null: false
      add :password_hash, :string
      add :email, :string
      add :phone, :string

      timestamps
    end

    create index(:users, [:username])
    create unique_index(:users, [:email])
  end
end
