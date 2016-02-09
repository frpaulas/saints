defmodule Saints.Repo.Migrations.AddPhoneLocation do
  use Ecto.Migration

  def change do
    alter table(:phones) do
      add :location, :text, default: "unknown"
    end  
  end
end
