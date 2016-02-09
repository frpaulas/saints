defmodule Saints.Note do
  use Saints.Web, :model
  schema "notes" do
    # field :donor_id, :integer
    field :author, :string     
    field :memo, :string     
    timestamps
    belongs_to :donor, Saints.Donor 
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(memo), ~w(author))
  end

end

defimpl Poison.Encoder, for: Saints.Note  do
  def encode(model, opts) do
    %{  id: model.id,
        author: model.author,
        memo: model.memo,
        updated_at: model.updated_at
      } |> Poison.Encoder.encode(opts)
  end
end