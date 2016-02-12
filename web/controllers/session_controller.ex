require IEx
defmodule Saints.SessionController do
  use Saints.Web, :controller

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"username" => user, "password" => pass}}) do
    create_after_validation(Saints.Auth.validate_user(conn, user, pass, repo: Repo))
  end

  defp create_after_validation({:ok, conn}) do
    conn
    |> put_flash(:info, "Welcome back!")
    |> redirect(to: donor_path(conn, :index))
  end
  defp create_after_validation({:error, _reason, conn}) do
    conn
    |> put_flash(:error, "Invalid username/password combination")
    |> render("new.html")
  end

  def delete(conn, _) do
    conn
    |> Saints.Auth.logout()
    |> put_flash(:info, "You have been logged out")
    |> redirect(to: donor_path(conn, :index))
  end

end