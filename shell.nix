{ pkgs, MIX_ENV }:

with pkgs; mkShell
{
  buildInputs = [ mix2nix rebar3 ]
    ++ lib.optional stdenv.isLinux inotify-tools
    ++ lib.optionals stdenv.isDarwin
    (with darwin.apple_sdk.frameworks; [ CoreFoundation CoreServices ]);

  inputsFrom = [ pkgs.cpub ];

  shellHook = ''
    # this allows mix to work on the local directory
    mkdir -p $PWD/.nix-mix
    mkdir -p $PWD/.nix-hex
    export MIX_HOME=$PWD/.nix-mix
    export HEX_HOME=$PWD/.nix-mix
    export PATH=$MIX_HOME/bin:$PATH
    export PATH=$HEX_HOME/bin:$PATH
    mix local.hex --if-missing
    export LANG=en_US.UTF-8
    export ERL_AFLAGS="-kernel shell_history enabled"
    export MIX_REBAR3="${rebar3}/bin/rebar3";


    # elixir
    export POOL_SIZE=15
    export PORT=4000
    export MIX_ENV=${MIX_ENV}
  '';
}
