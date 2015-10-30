defmodule Saints.Repo.Migrations.CreateAddress do
  use Ecto.Migration

  def change do
    create table(:address) do
      add :donor_id, references(:donor)     
      add :location, :string, null: false   
      add :address1, :string      
      add :address2, :string     
      add :city, :string     
      add :state, :string      
      add :zip, :string      
      add :country, :string      
      
      timestamps
    end
    create index(:address, [:donor_id])
  end
end
