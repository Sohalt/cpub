defmodule CPub.Web.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """

  use CPub.Web, :controller

  alias CPub.Web.ChangesetView

  @type error_tuple :: {:error, String.Chars.t() | atom}

  @spec call(Plug.Conn.t(), error_tuple) :: Plug.Conn.t()

  def call(%Plug.Conn{} = conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> text("Not found")
  end

  def call(%Plug.Conn{} = conn, {:error, :bad_request}) do
    conn
    |> put_status(:bad_request)
    |> text("Bad request")
  end

  def call(%Plug.Conn{} = conn, {:error, :unahtorized}) do
    conn
    |> put_status(:unauthorized)
    |> text("Unauthorized")
  end

  def call(%Plug.Conn{} = conn, {:error, "Invalid argument; Not a valid UUID: " <> _ = msg}) do
    conn
    |> put_status(400)
    |> text(msg)
  end

  def call(%Plug.Conn{} = conn, {:error, msg}) do
    conn
    |> put_status(500)
    |> text(msg)
  end
end
