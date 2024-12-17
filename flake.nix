{
  description = "Hello world flake using clj-nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";

    clj-nix.url = "github:jlesquembre/clj-nix";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      devshell,
      clj-nix,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (system: let
      inherit (nixpkgs) lib;

      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          devshell.overlays.default
        ];
      };

    in {
      packages.default = let
        kernel = clj-nix.lib.mkCljApp {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            {
              # projectSrc = modifiedSrc;
              projectSrc = ./.;
              name = "sh54.pygpu/kernel";
              version = "1.0";
              main-ns = "user";

              # buildCommand = "clj -T:build uber";

              buildCommand = ''clj -X:build:prod uberjar :build/jar-name "target/clojupyter-standalone.jar"'';
              # buildCommand = ''clj -X:build:prod something :build/jar-name "clojupyter-standalone.jar"'';

              # buildCommand = ''clj -X:build:prod uberjar'';

              # buildCommand = ''clojure -A:depstar -m hf.depstar.uberjar clojupyter-standalone.jar'';
              # builder-extra-inputs = [
              #   pkgs.tailwindcss
              # ];

              # nativeImage.enable = true;
              # customJdk.enable = true;
            }
          ];
        };
      in kernel;

      devShells = {
        default =
          let
            x = 1;
          in pkgs.devshell.mkShell {
            packages = [
              pkgs.nodejs_23
              pkgs.clojure
              pkgs.zulu23
              pkgs.git
            ];
            devshell.startup.remove-fake-git.text = ''
            '';
            commands = [
            ];
          };
      };
    });
}
