defmodule Saints.Address do
  use Saints.Web, :model
  schema "addresses" do
    # field :donor_id, :integer     
    field :location, :string, default: "home"
    field :address1, :string, default: ""
    field :address2, :string, default: ""
    field :city, :string, default: ""
    field :state, :string, default: ""
    field :zip, :string, default: ""
    field :country, :string, default: ""
    belongs_to :donor, Saints.Donor
    
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(location), ~w(address1 address2 city state zip country))
    |> validate_inclusion(:location, ~w(unknown home office church vacation))
  end

end

defimpl Poison.Encoder, for: Saints.Address  do
  def encode(model, opts) do
    %{  id: model.id,
        location: model.location,
        address1: model.address1,
        address2: model.address2,
        city: model.city,
        state: model.state,
        zip: model.zip,
        country: model.country
      } |> Poison.Encoder.encode(opts)
  end
end