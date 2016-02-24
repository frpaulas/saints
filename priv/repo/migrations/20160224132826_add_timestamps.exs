defmodule Saints.Repo.Migrations.AddTimestamps do
  use Ecto.Migration

  def change do
    alter table(:addresses) do
      add :inserted_at, :datetime, default: fragment("now()")
      add :updated_at, :datetime, default: fragment("now()")
    end 
    alter table(:donor) do
      add :inserted_at, :datetime, default: fragment("now()")
      add :updated_at, :datetime, default: fragment("now()")
    end 
    alter table(:phones) do
      add :inserted_at, :datetime, default: fragment("now()")
      add :updated_at, :datetime, default: fragment("now()")
    end
  end
end
