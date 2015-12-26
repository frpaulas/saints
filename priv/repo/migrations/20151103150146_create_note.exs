defmodule Saints.Repo.Migrations.CreateNote do
  use Ecto.Migration

  def change do
    create table(:note) do
      add :donor_id, references(:donor)
      add :memo, :string, null: false

      timestamps
    end
    create index(:note, [:donor_id])
  end
end
