defmodule CPub.Web.ObjectController do
  use CPub.Web, :controller

  alias CPub.{Object, Repo}

  action_fallback CPub.Web.FallbackController

  def show(conn, _params) do
    object = Repo.get!(Object, conn.assigns[:id])

    conn
    |> put_view(RDFView)
    |> render(:show, data: object.data)
  end
end