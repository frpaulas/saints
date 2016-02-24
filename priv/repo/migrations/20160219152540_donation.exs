defmodule Saints.Repo.Migrations.Donation do
  use Ecto.Migration

  def change do
    create table(:donations) do
      add :donor_id, references(:donor)
      add :amount, :decimal, precision: 8, scale: 2, default: 0
      add :of_type, :string, default: "check" # e.g. check, cash, paypal
      add :of_type_id, :string, default: "" # check no., paypal trans. id, etc.

      timestamps
    end
    create index(:donations, [:donor_id])
  end
end
