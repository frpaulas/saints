require IEx
defmodule Saints.Donor do
  use Saints.Web, :model

  schema "donor" do
    # field :donor_id, :integer     
    field :title, :string     
    field :first_name, :string      
    field :middle_name, :string     
    field :last_name, :string     
    field :name_ext, :string  
    has_many :addresses, Saints.Address
    has_many :phones, Saints.Phone 
    has_many :notes, Saints.Note   
    
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(last_name), ~w(title first_name middle_name name_ext))
    |> cast_assoc(:addresses, require: true)
    |> cast_assoc(:phones, require: true)
    |> cast_assoc(:notes, require: true)
  end
  def changename(model, params \\ :empty) do
    model
    |> cast(params, ~w(last_name), ~w(title first_name middle_name name_ext))
  end
end

defimpl Poison.Encoder, for: Saints.Donor  do
  def encode(model, opts) do
    %{  id:           model.id,
        title:        model.title,
        firstName:    model.first_name,
        middleName:   model.middle_name,
        lastName:     model.last_name,
        nameExt:      model.name_ext,
        addresses:    (if Ecto.assoc_loaded?( model.addresses ),  do: model.addresses,     else: []),
        phones:       (if Ecto.assoc_loaded?( model.phones ),     do: model.phones,        else: []),
        notes:        (if Ecto.assoc_loaded?( model.notes ),      do: model.notes,         else: []),
      } |> Poison.Encoder.encode(opts)
  end
end