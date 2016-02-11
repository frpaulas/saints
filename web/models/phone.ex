defmodule Saints.Phone do
  use Saints.Web, :model
  schema "phones" do
    field :location, :string
    field :of_type, :string     
    field :number, :string      
    belongs_to :donor, Saints.Donor
    
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(of_type number), ~w(location))
    |> validate_inclusion(:location, ~w(home office away mobil unknown))
    |> validate_inclusion(:of_type, ~w(phone email fax url pager))
  end

end

defimpl Poison.Encoder, for: Saints.Phone  do
  def encode(model, opts) do
    %{  id: model.id,
        donor_id: model.donor_id,
        location: model.location,
        ofType: model.of_type,
        number: model.number
      } |> Poison.Encoder.encode(opts)
  end
end