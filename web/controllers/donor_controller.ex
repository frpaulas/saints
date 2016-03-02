defmodule Saints.DonorController do
  use Saints.Web, :controller
  import Saints.Authenticate, only: [authenticate: 2]
#  plug :authenticate when action in [:index, :show, :new, :create]
  plug :authenticate when action in [:show, :new, :create, :index]
  alias Saints.Donor

  def index(conn, params) do
    render conn, "index.html" # turn it over to Elm
  end

end