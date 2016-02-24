defmodule Saints.Repo.Migrations.CreatePhone do
  use Ecto.Migration

  def change do
    create table(:phones) do
      add :donor_id, references(:donor)    
      add :of_type, :string, null: false   
      add :number, :string, null: false
      add :location, :string, default: "unknown"
      
      timestamps
    end
    create index(:phones, [:number])
    create index(:phones, [:donor_id])
  end
end
