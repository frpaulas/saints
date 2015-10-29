defmodule Saints.Auth do
  import Plug.Conn

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    user_id = get_session(conn, :user_id)
    user    = user_id && repo.get(Saints.User, user_id)
    assign(conn, :current_user, user)
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end


  import Comeonin.Bcrypt, only: [checkpw: 2]
  def validate_user(conn, username, given_pass, opts) do
    repo = Keyword.fetch!(opts, :repo)
    find_the_user conn, repo.get_by(Saints.User, username: username), given_pass
  end
  defp find_the_user(conn, nil, _), do: {:error, :not_found, conn}
  defp find_the_user(conn, user, given_pass), do: check_the_password(conn, user, checkpw(given_pass, user.password_hash))
  defp check_the_password(conn, user, true), do: {:ok, login(conn, user)}
  defp check_the_password(conn, _user, _), do: {:error, :unauthorized, conn}

end