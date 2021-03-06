# SPDX-FileCopyrightText: 2020-2021 pukkamustard <pukkamustard@posteo.net>
# SPDX-FileCopyrightText: 2020-2021 rustra <rustra@disroot.org>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

defmodule CPub.Web.Authorization.Client do
  @moduledoc """
  An OAuth 2.0 client that authenticates with CPub (see
  https://tools.ietf.org/html/rfc6749#section-2).

  A client holds some metadata such as a human readable name (`:client_name`)
  and the authorization scopes (`:scopes`) the client can request.
  """

  use Memento.Table,
    attributes: [
      :id,

      # Client Metadata
      # See also https://tools.ietf.org/html/rfc7591#section-2

      # list of permitted redirect_uris
      :redirect_uris,

      # human readable client name
      :client_name,

      # list of permitted scopes
      :scope,

      # client secret
      :client_secret
    ],
    type: :set

  alias CPub.DB

  alias CPub.Web.Authorization

  @type t :: %__MODULE__{
          id: String.t(),
          redirect_uris: [String.t()],
          client_name: String.t(),
          scope: [String.t()],
          client_secret: String.t()
        }

  @doc """
  Create a new OAuth 2.0 client
  """
  @spec create(map) :: {:ok, t} | {:error, any}
  def create(attrs) do
    DB.transaction(fn ->
      with {:ok, scope} <- Authorization.Scope.parse(Map.get(attrs, "scope")),
           redirect_uris <- Map.get(attrs, "redirect_uris"),
           true <- is_list(redirect_uris) and Enum.all?(redirect_uris, &is_binary/1) do
        %__MODULE__{
          id: UUID.uuid4(),
          redirect_uris: redirect_uris,
          client_name: Map.get(attrs, "client_name"),
          scope: scope,
          client_secret: random_secret()
        }
        |> Memento.Query.write()
      else
        _ ->
          DB.abort(:invalid_client)
      end
    end)
  end

  @doc """
  Get a client by `id`.
  """
  @spec get(String.t()) :: {:ok, t} | {:error, any}
  def get(id) do
    DB.transaction(fn ->
      Memento.Query.read(__MODULE__, id)
    end)
  end

  @doc """
  Returns a single redirect uri.

  If `params` contains a `"redirect_uri"` key the value will be checked to match
  the `redirect_uris` of the client.

  If `params` does not contain a `redirect_uri` the first uri from
  client.redirect_uris will be used.
  """
  @spec get_redirect_uri(t, map) :: {:ok, URI.t()} | :error
  def get_redirect_uri(%__MODULE__{} = client, %{} = params) do
    params
    |> Map.get("redirect_uri", client.redirect_uris |> List.first())
    |> redirect_uri_valid?(client)
  end

  # Check if redirect uri is valid for client
  @spec redirect_uri_valid?(String.t(), t) :: {:ok, URI.t()} | :error
  defp redirect_uri_valid?(uri, %__MODULE__{} = client) do
    if uri in client.redirect_uris do
      {:ok, URI.parse(uri)}
    else
      :error
    end
  end

  @spec random_secret :: String.t()
  defp random_secret do
    :crypto.strong_rand_bytes(32)
    |> Base.encode32(padding: false)
  end
end
