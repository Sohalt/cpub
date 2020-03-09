defmodule CPub.Web.Router do
  use CPub.Web, :router

  @doc """
  Cast the request URL to a valid ID (IRI) and assign to connection.

  This is useful as the id for an object being accessed is usually the request url.
  """
  def assign_id(conn, _opts) do
    case request_url(conn) |> CPub.ID.cast() do
      {:ok, id} ->
        conn
        |> assign(:id, id)

      _ ->
        conn
    end
  end

  pipeline :api do
    plug :accepts, ["json", "ttl"]
    plug :assign_id
  end

  pipeline :optionally_authenticated do
    # This pipeline authenticates a user but does not fail.
    # This is useful for endpoints that can be accessed by non-authenticated
    # users and authenticated users. But authenticated users get a different
    # response.
    plug CPub.Web.Authentication
  end

  pipeline :authenticated do
    # This pipeline requires connection to be authenticated.
    # If not a 401 is returned and connection is halted.
    plug CPub.Web.Authentication.Required
  end

  scope "/", CPub.Web do
    pipe_through :api

    resources "/activities", ActivityController, only: [:show]
    resources "/objects", ObjectController, only: [:show]
    get "/public", PublicController, :get_public
  end

  scope "/users", CPub.Web do
    pipe_through :api
    pipe_through :optionally_authenticated

    resources "/", UserController, only: [:show] do
      pipe_through :authenticated
      post "/outbox", UserController, :post_to_outbox
      get "/outbox", UserController, :get_outbox
      get "/inbox", UserController, :get_inbox
    end
  end
end