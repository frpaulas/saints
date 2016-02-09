defmodule Saints.Repo.Migrations.AddAuthorToNote do
  use Ecto.Migration

  def change do
    alter table(:notes) do
      add :author, :text, default: "unknown"
    end  
  end
end
