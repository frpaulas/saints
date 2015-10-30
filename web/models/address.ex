defmodule Saints.Address do
  use Saints.Web, :model
  schema "address" do
    # field :donor_id, :integer     
    field :location, :string     
    field :address1, :string      
    field :address2, :string     
    field :city, :string     
    field :state, :string      
    field :zip, :string      
    field :country, :string      
    belongs_to :donor, Saints.Donor
    
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(location), ~w(address1 address2 city state zip country))
  end

end
