defmodule Saints.Repo.Migrations.AddDonorTable do
  use Ecto.Migration

  def change do
    create table(:donor) do
      add :title, :string     
      add :first_name, :string      
      add :middle_name, :string     
      add :last_name, :string, null: false     
      add :name_ext, :string      

      timestamps
    end

    create index(:donor, [:last_name], unique: false)
  end
end
