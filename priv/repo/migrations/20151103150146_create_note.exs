defmodule Saints.Repo.Migrations.CreateNote do
  use Ecto.Migration

  def change do
    create table(:notes) do
      add :donor_id, references(:donor)
      add :memo, :string, null: false
      add :author, :string, default: "unknown"

      timestamps
    end
    create index(:notes, [:donor_id])
  end
end
