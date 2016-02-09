defmodule Saints.Phone do
  use Saints.Web, :model
  schema "phones" do
    field :of_type, :string     
    field :number, :string      
    belongs_to :donor, Saints.Donor
    
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(of_type number), [])
    |> validate_inclusion(:of_type, ~w(home office away other mobil email fax url pager))
  end

end

defimpl Poison.Encoder, for: Saints.Phone  do
  def encode(model, opts) do
    %{  id: model.id,
        ofType: model.of_type,
        number: model.number
      } |> Poison.Encoder.encode(opts)
  end
end