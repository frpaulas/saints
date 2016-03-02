require IEx
defmodule Saints.UserController do
  use Saints.Web, :controller
  import Saints.Authenticate, only: [authenticate: 2]
  plug :authenticate when action in [:index, :show, :new, :create]
  alias Saints.User

  def index(conn, _params) do
    render conn, "index.html", users: Repo.all(User)
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get User, id
    render conn, "show.html", user: user
  end

  def new(conn, _params) do
    if conn.assigns.current_user.admin do
      changeset = User.changeset %User{}
      render conn, "new.html", changeset: changeset
    else
      conn
      |> put_flash( :error, "Only administrator may add users" )
      |> redirect( to: donor_path(conn, :index) )
    end
  end

  def create(conn, %{"user" => user_params}) do
    _create conn, ok_to_insert(user_params)
  end

# private functions

  defp ok_to_insert(user_params) do
    Repo.insert User.registration_changeset(%User{}, user_params)
  end
  defp _create(conn, {:ok, user}) do
    conn
    |> put_flash(:info, "#{user.name} created")
    |> redirect(to: user_path(conn, :index))
  end
  defp _create(conn, {:error, changeset}) do
    render(conn, "new.html", changeset: changeset)
  end

end