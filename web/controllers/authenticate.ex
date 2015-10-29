defmodule Saints.Authenticate do
  use Saints.Web, :controller

  def authenticate(conn, _opts) do
    is_authentic conn, conn.assigns.current_user
  end
  def is_authentic(conn, nil) do # nope, it's not
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: page_path(conn, :index))
      |> halt()
  end
  def is_authentic(conn, _), do: conn


end