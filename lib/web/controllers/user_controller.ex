defmodule CPub.Web.UserController do
  use CPub.Web, :controller

  alias CPub.{ActivityPub, ID, Repo, User}
  alias RDF.{Graph, IRI, Turtle}

  action_fallback CPub.Web.FallbackController

  @spec show(Plug.Conn.t(), map) :: Plug.Conn.t()
  def show(%Plug.Conn{assigns: %{id: user_id}} = conn, _params) do
    with {:ok, user} <- Repo.get_one(User, user_id),
         profile <- Graph.set_base_iri(user.profile, IRI.new!("#{user_id}/")) do
      conn
      |> put_view(RDFView)
      |> render(:show, data: profile)
    end
  end

  @spec show_me(Plug.Conn.t(), map) :: Plug.Conn.t()
  def show_me(%Plug.Conn{assigns: %{id: user_id}} = conn, _params) do
    id =
      user_id.value
      |> String.trim_trailing("/me")
      |> IRI.new!()

    with {:ok, user} <- Repo.get_one(User, id),
         {:ok, me} <- Graph.fetch(user.profile, id),
         me <- Graph.set_base_iri(Graph.new(me), IRI.new!("#{id}/")) do
      conn
      |> put_view(RDFView)
      |> render(:show, data: me)
    end
  end

  @spec id(Plug.Conn.t(), map) :: Plug.Conn.t()
  def id(%{assigns: %{user: %User{id: user_id} = user}} = conn, _params) do
    profile = Graph.set_base_iri(user.profile, IRI.new!("#{user_id}/"))

    conn
    |> put_view(RDFView)
    |> render(:show, data: profile)
  end

  @spec verify(Plug.Conn.t(), map) :: Plug.Conn.t()
  def verify(%{assigns: %{user: %User{username: username}}} = conn, _params) do
    json(conn, %{username: username})
  end

  @spec read_rdf_body(Plug.Conn.t(), keyword) ::
          {:ok, RDF.Graph.t() | RDF.Dataset.t(), Plug.Conn.t()} | {:error, any}
  defp read_rdf_body(%Plug.Conn{} = conn, opts) do
    with {:ok, body, conn} <- read_body(conn),
         {:ok, data} <- Turtle.Decoder.decode(body, opts) do
      {:ok, data, conn}
    end
  end

  @spec post_to_outbox(Plug.Conn.t(), map) :: Plug.Conn.t()
  def post_to_outbox(%Plug.Conn{assigns: %{user: %User{} = user}} = conn, _params) do
    with activity_id <- ID.generate(type: :activity),
         {:ok, data, conn} <- read_rdf_body(conn, base_iri: activity_id),
         {:ok, %{activity: activity}} <- ActivityPub.handle_activity(activity_id, data, user) do
      conn
      |> put_resp_header("Location", IRI.to_string(activity.id))
      |> send_resp(:created, "")
    end
  end

  @spec get_inbox(Plug.Conn.t(), map) :: Plug.Conn.t()
  def get_inbox(%Plug.Conn{assigns: %{id: user_id, user: %User{} = user}} = conn, _params) do
    if User.get_inbox_id(user) == user_id do
      data = User.get_inbox(user)

      conn
      |> put_view(RDFView)
      |> render(:show, data: data)
    else
      unauthorized(conn)
    end
  end

  @spec get_outbox(Plug.Conn.t(), map) :: Plug.Conn.t()
  def get_outbox(%Plug.Conn{assigns: %{id: user_id, user: %User{} = user}} = conn, _params) do
    if User.get_outbox_id(user) == user_id do
      data = User.get_outbox(user)

      conn
      |> put_view(RDFView)
      |> render(:show, data: data)
    else
      unauthorized(conn)
    end
  end
end
