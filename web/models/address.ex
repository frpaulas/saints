defmodule Saints.Address do
  use Saints.Web, :model
  schema "address" do
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
  end

end
