# SPDX-FileCopyrightText: 2020-2021 rustra <rustra@disroot.org>
# SPDX-FileCopyrightText: 2017-2021 Pleroma Authors <https://pleroma.social/>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

defmodule CPub.HTTP.Gun.API do
  @moduledoc false

  @behaviour CPub.HTTP.Gun

  alias CPub.HTTP.Gun

  @gun_keys [
    :connect_timeout,
    :http_opts,
    :http2_opts,
    :protocols,
    :retry,
    :retry_timeout,
    :trace,
    :transport,
    :tls_opts,
    :tcp_opts,
    :socks_opts,
    :ws_opts,
    :supervise
  ]

  @impl Gun
  def open(host, port, opts \\ %{}), do: :gun.open(host, port, Map.take(opts, @gun_keys))

  @impl Gun
  defdelegate info(pid), to: :gun

  @impl Gun
  defdelegate close(pid), to: :gun

  @impl Gun
  defdelegate await_up(pid, timeout \\ 5_000), to: :gun

  @impl Gun
  defdelegate connect(pid, opts), to: :gun

  @impl Gun
  defdelegate await(pid, ref), to: :gun

  @impl Gun
  defdelegate set_owner(pid, owner), to: :gun
end
