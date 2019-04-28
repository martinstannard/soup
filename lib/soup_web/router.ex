defmodule SoupWeb.Router do
  use SoupWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SoupWeb do
    pipe_through :browser

    get "/", PageController, :index
    post "/game", PageController, :game
  end

  # Other scopes may use custom stacks.
  # scope "/api", SoupWeb do
  #   pipe_through :api
  # end
end
