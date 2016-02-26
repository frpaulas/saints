import IEx
defmodule Saints.Donation do
  use Saints.Web, :model

  schema "donations" do
    field :amount, :decimal, precision: 5, scale: 2 # in pennies, convert to dollars/cents elsewhere
    field :of_type, :string # e.g. check, cash, paypal
    field :of_type_id, :string # check no., paypal trans. id, etc.
    timestamps
    belongs_to :donor, Saints.Donor
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(amount), ~w(of_type of_type_id))
  end
end

defimpl Poison.Encoder, for: Saints.Donation do
  def encode(model, opts) do
    %{  id: model.id,
        donor_id: model.donor_id,
        amount: model.amount,
        ofType: model.of_type,
        ofTypeID: model.of_type_id,
        updated_at: (if model.updated_at, do: model.updated_at, else: Ecto.DateTime.local)
      } |> Poison.Encoder.encode(opts)
  end

end