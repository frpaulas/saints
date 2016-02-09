defmodule Saints.Repo.Migrations.ChangeTablesNames do
  use Ecto.Migration

  def change do
    rename table(:note), to: table(:notes)
    rename table(:address), to: table(:addresses)
    rename table(:phone), to: table(:phones)
  end
end
