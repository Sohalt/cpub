{
  description = "A semantic ActivityPub server.";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    #nixpkgs.url = "nixpkgs/nixos-21.05";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    let

      # Generate a user-friendly version numer.
      version = builtins.substring 0 8 self.lastModifiedDate;

      # System types to support.
      supportedSystems = [ "x86_64-linux" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });

      mixNixDeps' = pkgs: with pkgs; import ./deps.nix {
            inherit beamPackages lib;
            overrides = (final: prev: {
              mime = prev.mime.override {
                patchPhase =
                  let
                    cfgFile = writeText "config.exs" ''
                      use Mix.Config
                      config :mime, :types, %{
                        "application/ld+json" => ["jsonld"],
                        "application/rdf+json" => ["rj"],
                        "text/turtle" => ["ttl"]
                      }
                    '';
                  in
                  ''
                    mkdir config
                    cp ${cfgFile} config/config.exs
                  '';
              };
              # mix2nix currently cannot deal with git dependencies, so they are added here
              eris = beamPackages.buildMix rec {
                name = "eris";
                version = "main";
                src = fetchFromGitLab {
                  owner = "openengiadina";
                  repo = "elixir-eris";
                  rev = "a1b7c4bc030f8d3b651b3f1d9a60bce369ff6fe2";
                  sha256 = "uWpTuimyMYJyTdQbg63CqwH2xcgHb6kPqzTQ5jTzZwA=";
                };
              };
              monocypher = beamPackages.buildRebar3 rec {
                name = "monocypher";
                version = "main";
                src = fetchFromGitLab {
                  owner = "openengiadina";
                  repo = "erlang-monocypher";
                  rev = "58e007de05e6be3ee62662e0f85860b0848d2ff6";
                  sha256 = "HXU6HzDqPXONNeQ3wS4sILbOacXD8Om86XeLR5tTxGU=";
                };
              };
              rdf = beamPackages.buildMix rec {
                name = "rdf";
                version = "master";
                src = fetchFromGitHub {
                  owner = "rdf-elixir";
                  repo = "rdf-ex";
                  rev = "857079b256303b5ae9efef795f6b043e80c3b837";
                  sha256 = "FzDQwvOdCudvvvk5oBXLNfL+1gAiHFgHcAuufRteGzU=";
                };
                beamDeps = with final; [ decimal protocol_ex ];
              };
            });
          };
    in
    {
      overlay = final: prev: {
        cpub = with final; let
          mixNixDeps = mixNixDeps' final;
        in
          beamPackages.mixRelease {
            inherit mixNixDeps;
            pname = "cpub";
            src = ./.;
            version = "0.2.0"; # FIXME
            preConfigure = ''
              touch config/prod.secret.exs
            '';
            postInstall = ''
              echo "${beamPackages.erlang.version}" > $out/OTP_VERSION
            '';
          };
      };
      packages = forAllSystems (system:
        {
          inherit (nixpkgsFor.${system}) cpub;
        });
      defaultPackage = forAllSystems (system: self.packages.${system}.cpub);
      devShell = forAllSystems (system:
        let
          pkgs = nixpkgsFor."${system}";
        in
        pkgs.mkShell {
          inputsFrom = builtins.attrValues self.packages.${system};
        });
      nixosModules.cpub = { config, lib, ... }:
        with lib;
        let cfg = config.services.cpub;
        in
        {
          options = {
            services.cpub = {
              enable = mkEnableOption "Cpub, a semantic ActivityPub server";
              domain = mkOption {
                type = types.str;
                default = "localhost";
              };
              port = mkOption {
                type = types.port;
                default = 4000;
              };
              databaseDir = mkOption {
                type = str;
                default = "/var/lib/cpub";
              };
              #secrets
              cookieFile = mkOption {
                type = str;
              };
              secretKeyBaseFile = mkOption {
                type = str;
              };
              jokenRSAKey = mkOption {
                type = str;
              };
            };
          };
          config = mkIf cfg.enable {
            systemd.services.cpub = {
              description = "";
              after = [ "network.target" ];
              wantedBy = [ "multi-user.target" ];

              environment.COOKIE = "<(${cookieFile})";

              serviceConfig = {
                ExecStart = "${pkgs.cpub}/bin/cpub start";
              };
            };
          };
        };
    };
}
