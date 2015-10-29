defmodule Saints.DonorController do
  use Saints.Web, :controller
  import Saints.Authenticate, only: [authenticate: 2]
  plug :authenticate when action in [:index, :show, :new, :create]
  alias Saints.Donor

  def index(conn, _params) do
    donors = Repo.all(Saints.Donor)
    render conn, "index.html", donors: donors
  end

  def show(conn, %{"id" => donor_id}) do
    donor = Repo.get(Saints.Donor, donor_id)
    render conn, "show.html", donor: donor
  end

  def new(conn, _params) do
    changeset = Donor.changeset %Donor{}
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => donor_params}) do
    changeset = Donor.changeset(%Donor{}, donor_params)
    case Repo.insert(changeset) do
      {:ok, donor} ->
        conn
        |> put_flash(:info, "#{donor.name} created")
        |> redirect(to: donor_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

def put_prefix(query, prefix) do
  query = Ecto.Queryable.to_query(query)
  %{query | prefix: prefix}
end

end