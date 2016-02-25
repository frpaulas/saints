defmodule Saints.User do
  use Saints.Web, :model
  schema "users" do
    field :name, :string
    field :password,      :string, virtual: true
    field :username,      :string, null: false
    field :password_hash, :string
    field :email,         :string
    field :phone,         :string
    field :admin,         :boolean, default: false
    
    timestamps
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(name username), ~w(email phone))
    |> validate_length(:username, min: 1, max: 20)
  end

  def registration_changeset(model, params) do
    model
    |> changeset(params)
    |> cast(params, ~w(password), [])
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_hash()
  end
  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ -> 
        changeset
      end
  end

end

