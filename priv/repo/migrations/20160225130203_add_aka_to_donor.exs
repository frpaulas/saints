defmodule Saints.Repo.Migrations.AddAkaToDonor do
  use Ecto.Migration

  def change do
    alter table(:donor) do
      add :aka, :string, default: ""
    end
  end
end
