defmodule Saints.Donor do
  use Saints.Web, :model
  schema "donor" do
    # field :donor_id, :integer     
    field :title, :string     
    field :first_name, :string      
    field :middle_name, :string     
    field :last_name, :string     
    field :name_ext, :string      
    
    timestamps
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(last_name), ~w(title first_name middle_name last_name name_ext))
  end

end
