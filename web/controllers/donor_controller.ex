defmodule Saints.DonorController do
  use Saints.Web, :controller
  import Saints.Authenticate, only: [authenticate: 2]
#  plug :authenticate when action in [:index, :show, :new, :create]
  plug :authenticate when action in [:show, :new, :create]
  alias Saints.Donor

  def index(conn, params) do
    page
      = Saints.Donor
      |> where([d], true)
      |> order_by([d], [asc: d.last_name, asc: d.first_name])
      |> Repo.paginate(page: params["page"])
    case conn.private.phoenix_format do
      "html" ->
        render conn, "index.html", 
          donors:         page.entries,
          page_number:    page.page_number,
          page_size:      page.page_size,
          total_pages:    page.total_pages,
          total_entries:  page.total_entries
      "json" ->
        render conn, "index.json", donors: page.entries
    end
  end

  def alphaIndex(conn, params) do
    page
      = Saints.Donor
      |> where([d], like(d.last_name, ^("#{params["letter"]}%")) )
      |> order_by([d], [asc: d.last_name, asc: d.first_name])
      |> Repo.paginate(page: params["page"])
    render conn, "index.html", 
      donors:         page.entries,
      page_number:    page.page_number,
      page_size:      page.page_size,
      total_pages:    page.total_pages,
      total_entries:  page.total_entries
  end

  def show(conn, %{"id" => donor_id}) do
    donor = Repo.one( from d in Saints.Donor, 
                      where: d.id == ^donor_id, 
                      preload: [:addresses, :phones, :notes]
                    )
    render conn, "show.html", donor: donor
  end

  def edit(conn, %{"id" => donor_id}) do
    changeset = 
      Repo.one( from d in Saints.Donor,
                where: d.id == ^donor_id,
                preload: [:addresses, :phones, :notes]
              )
      |> Donor.changeset
    render conn, "edit.html", changeset: changeset
  end

  def new(conn, _params) do
    changeset = Donor.changeset %Donor{}
    render conn, "new.html", changeset: changeset
  end

  def update(conn, %{"id"=> donor_id, "donor" => donor_params}) do
    donor = Repo.one( from d in Saints.Donor, 
                      where: d.id == ^donor_id, 
                      preload: [:addresses, :phones, :notes]
                    )
    changeset = Donor.changeset(donor, donor_params)
    case Repo.update(changeset) do
      {:ok, donor} ->
        conn 
          |> put_flash(:info, "Donor updated successfully.")
          |> redirect(to: donor_path(conn, :show, donor))
      {:error, changeset} ->
        conn 
          |> render("edit.html", changeset: changeset)
    end
  end

  def create(conn, %{"donor" => donor_params}) do
    changeset = Donor.changeset(%Donor{}, donor_params)
    case Repo.insert(changeset) do
      {:ok, donor} ->
        conn
        |> put_flash(:info, "#{donor.first_name} #{donor.last_name} created")
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