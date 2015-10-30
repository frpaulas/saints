defmodule Saints.Group do
  use Saints.Web, :model
  schema "group" do
    # field :donor_id, :integer     
    field :name, :string     
    field :subname, :string      
    
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(name), ~w(subname))
  end

end
