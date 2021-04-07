defmodule LeroWeb.Router do
  use LeroWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :maybe_browser_auth do
    plug(Guardian.Plug.VerifyHeader, realm: "Bearer")
    plug(Guardian.Plug.LoadResource)
  end

  pipeline :authenticated do
    plug(Guardian.Plug.EnsureAuthenticated, %{"typ" => "access", handler: Lero.HttpErrorHandler})
  end

  scope "/api", LeroWeb do
    pipe_through [:api, :maybe_browser_auth]

    post("/login", UserController, :login)
    post("/register", UserController, :register)
  end

  scope "/api", LeroWeb do
    pipe_through [:api, :maybe_browser_auth, :authenticated]

    get("/user", UserController, :show)
    post("/user", UserController, :update)

    scope "/conversations" do
      get("/conversations", ConversationController, :index)
    end

    resources "/message", MessageController
    # resources "/conversation", ConversationController
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: LeroWeb.Telemetry
    end
  end
end
