defmodule Saints.DonorController do
  use Saints.Web, :controller
  import Saints.Authenticate, only: [authenticate: 2]
  plug :authenticate when action in [:index, :show, :new, :create]
  alias Saints.Donor

  def index(conn, params) do
    page
      = Saints.Donor
      |> where([d], true)
      |> order_by([d], [asc: d.last_name, asc: d.first_name])
      |> Repo.paginate(page: params["page"])
    render conn, "index.html", 
      donors:         page.entries,
      page_number:    page.page_number,
      page_size:      page.page_size,
      total_pages:    page.total_pages,
      total_entries:  page.total_entries
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
                      preload: [:address, :phone, :note])
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