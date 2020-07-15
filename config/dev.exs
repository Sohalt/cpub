use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.

config :cpub, CPub.Web.Endpoint,
  http: [port: System.get_env("PORT") || 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Note that this task requires Erlang/OTP 20 or later.
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Configure your database
config :cpub, CPub.Repo,
  username: "postgres",
  password: "postgres",
  database: "cpub_dev",
  hostname: "localhost",
  pool_size: 10

# Configure Joken
config :joken, default_signer: "secret"

config :joken,
  rs256: [
    signer_alg: "RS256",
    key_pem: """
    -----BEGIN RSA PRIVATE KEY-----
    MIIEowIBAAKCAQEA3aC20H/E2XQj7E+sHXNOYpaBvZ30kdUU84fetOh9oWnWVebD
    +LGIgD1GIvu2xDkeZnCjih49xG2UYkLBtSrhQoFCwVpfaHUOIbNiVhzYRdZ9rsK9
    mDcNzvwyn542BhbFpwq39lEkglkexduGJGCZrUpMWzR5kY5Z+HYZpcs52VL6ue8t
    tav0gKG7Q+qhaqPm931LUoL6ArPb4tIplOKzHxv2/81aa9gd/rJrj6H4h5ebs6ZB
    /p8e1+NDnU/03k71KwsF9KjVvCbFA7DBSh8ewqDde5FjtOGzT0NKDhRgQdUOFBEe
    xXFGZlIGenxRl/7fy0mWrKoVRf8ezc3QOP1bPwIDAQABAoIBABv4X3oa1e4XsTzu
    pSsmVTsuAXu7xpTtDnLZr+qm+Mv5Pnqi4BKv3SlKEmLx35QOHV8SUiFpRaRXrAVm
    pWnG2pz5EUKztBzLwRfRutRhWY4ezsfSffkK4axAuebZIbpM/27gdG0aun/U3YRc
    +yX2Jw7utIpCKiGLlKE9zmjVKBzcFty3pwyAT3UcTpSJ2GuhGgW9BIgKb8t24MDz
    iswDnOXZropV8N2aU8aaikcLUjkjUr5uBhnx7ahIgL8WdSFVUGnpwTubIWqjuFC9
    cmWl21VzYVDQTLYmyS68H+7LEOWtfj0tuGxIiYxwiTTUb6Z4O0ZzU9bxlyVWFidi
    x7Qy8okCgYEA/Irf9GCIg+GbzrA7pZB9JCaYkiw8qNcnkd5X4gAFkOsgWJFZB9X2
    qNQDPrKmfRjHUL4SV9Y2QyfcusoZk4nTIgbnH3RVFLR4+N9QWvDDYxoxBTf7cp4X
    PTAUOlP41SEVdXS3o082FVJWE/UobKYm8cf4CGzd6//utcy2QfZZhu0CgYEA4Kl8
    3IkAhyQPX7ioTK7NmbeiwdhW+V0cjCKdgp6pqfkYXFl0UP14LgrTTKHgm6Ohh1p0
    uuVWNOoN/izHoQD2dmdE1AsCeYIWgf+8wUAv2CegIum+z/zmZnmlRotuyBw/lVIg
    c3H9+Y0/5ZpK/xIZPs5nXhSLgDAU0jGgRAoKWVsCgYBjCX88UeMXfRFiJACwNBKv
    a6dno4uCVyYAcWabjZChPWQo948noIQjv0kqfFsIMgBwLKn64lnTSj2ozvrqviEb
    dgOLdU6sWP4b80+K6mJlae8RcdvdHhxU9ZbpLOcnhdrpfgVKORUnlWuGVh0tRpd9
    OAOQIkmBdJPDne1XvulrHQKBgAuC47DxHCPQhzEiZw02z7YWoLJKAXrZeIL9qxBs
    TMk2yDbDJqCXvDavu0/r43RWGAq1adHBun8PlxP0+22WfQpoFDDBN6k+LyUOE3/b
    aBgtP5lKXMqPbMbHaN6Kemyqdd+Sy7LenmLRB/sdwsX7CWwca1N4vgUdcZOrk0ip
    MwqNAoGBAMroAmMAlWECreynBY2lfyZjLoTHpj14zoG3hlDHuujCLi0mD8UXNur0
    g7mZUdeOKREILutZksenB2wSmpqTxja3RW4qY8fAW4L+Nyyu9qtMro5n9IKV7CEu
    eFUVUwO4RFVJInyNgdoCseb7jl//mGxcx8xonWyCwMm0dsgfE3IT
    -----END RSA PRIVATE KEY-----
    """
  ]

# Configure external OAuth providers
# config :ueberauth, Ueberauth,
#   base_path: "/auth",
#   providers: [
#     # WebID-OIDC (Solid)
#     solid: {CPub.Web.OAuth.Strategy.WebIDOIDC, []},
#     # OpenID Connect
#     oidc: {CPub.Web.OAuth.Strategy.OIDC, []},
#     # OAuth2
#     cpub: {CPub.Web.OAuth.Strategy.CPub, []},
#     pleroma: {CPub.Web.OAuth.Strategy.Pleroma, []}
#     # github: {Ueberauth.Strategy.Github, [allow_private_emails: true]},
#     # gitlab: {Ueberauth.Strategy.Gitlab, [default_scope: "read_user"]},
#     # discord: {Ueberauth.Strategy.Discord, [default_scope: "identify"]}
#   ]

# config :ueberauth, CPub.Web.OAuth.Strategy.OIDC.OAuth,
#   oidc_cpub: [
#     register_client_url: "/auth/apps",
#     authorize_url: "/auth/authorize",
#     token_url: "/auth/token",
#     userinfo_url: "/auth/userinfo"
#   ]

# oidc_gitlab: [
#   site: "https://gitlab.com",
#   authorize_url: "https://gitlab.com/oauth/authorize",
#   token_url: "https://gitlab.com/oauth/token",
#   userinfo_url: "https://gitlab.com/oauth/userinfo",
#   client_id: System.get_env("OIDC_GITLAB_CLIENT_ID"),
#   client_secret: System.get_env("OIDC_GITLAB_CLIENT_SECRET")
# ],
# oidc_microsoft: [
#   # site: "https://graph.microsoft.com",
#   site: "https://login.microsoftonline.com",
#   authorize_url: "https://login.microsoftonline.com/common/oauth2/v2.0/authorize",
#   token_url: "https://login.microsoftonline.com/common/oauth2/v2.0/token",
#   # userinfo_endpoint: "/oidc/userinfo",
#   userinfo_endpoint: "/common/openid/userinfo",
#   client_id: System.get_env("OIDC_MICROSOFT_CLIENT_ID"),
#   client_secret: System.get_env("OIDC_MICROSOFT_CLIENT_SECRET")
# ]

# config :ueberauth, Ueberauth.Strategy.Github.OAuth,
#   client_id: System.get_env("GITHUB_CLIENT_ID"),
#   client_secret: System.get_env("GITHUB_CLIENT_SECRET")

# config :ueberauth, Ueberauth.Strategy.Gitlab.OAuth,
#   client_id: System.get_env("GITLAB_CLIENT_ID"),
#   client_secret: System.get_env("GITLAB_CLIENT_SECRET")

# config :ueberauth, Ueberauth.Strategy.Discord.OAuth,
#   client_id: System.get_env("DISCORD_CLIENT_ID"),
#   client_secret: System.get_env("DISCORD_CLIENT_SECRET")
