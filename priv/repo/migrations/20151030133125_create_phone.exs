defmodule Saints.Repo.Migrations.CreatePhone do
  use Ecto.Migration

  def change do
    create table(:phone) do
      add :donor_id, references(:donor)    
      add :of_type, :string, null: false   
      add :number, :string, null: false
      
      timestamps
    end
    create unique_index(:phone, [:number])
    create index(:phone, [:donor_id])
  end
end
