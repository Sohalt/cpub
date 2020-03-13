defmodule CPub.Web.ActivityController do
  use CPub.Web, :controller

  alias CPub.{Activity, Repo}

  action_fallback CPub.Web.FallbackController

  @spec show(Plug.Conn.t(), map) :: Plug.Conn.t()
  def show(conn, _params) do
    activity =
      Activity
      |> Repo.get!(conn.assigns[:id])
      |> Repo.preload(:object)

    conn
    |> put_view(RDFView)
    |> render(:show, data: Activity.to_rdf(activity))
  end
end
