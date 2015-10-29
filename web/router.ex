defmodule Saints.Router do
  use Saints.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Saints.Auth, repo: Saints.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Saints do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    resources "/users", UserController
    resources "/session", SessionController, only: [:new, :create, :delete]
    resources "/donors", DonorController
  end

  # Other scopes may use custom stacks.
  # scope "/api", Saints do
  #   pipe_through :api
  # end
end
