defmodule Saints.Phone do
  use Saints.Web, :model
  schema "phone" do
    # field :donor_id, :integer     
    field :of_type, :string     
    field :number, :string      
    belongs_to :donor, Saints.Donor
    
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(of_type number), [])
  end

end
