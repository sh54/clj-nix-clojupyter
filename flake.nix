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
              projectSrc = ./.;
              name = "sh54.pygpu/kernel";
              version = "1.0";
              main-ns = "user";
              buildCommand = ''clj -X:build:prod uberjar :build/jar-name "target/clojupyter-standalone.jar"'';
            }
          ];
        };
      in kernel;

      packages.troubleshoot = let
        kernel = clj-nix.lib.mkCljApp {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            {
              # projectSrc = modifiedSrc;
              projectSrc = ./.;
              name = "sh54.pygpu/kernel";
              version = "1.0";
              main-ns = "user";

              buildCommand = ''
                echo "==> Debugging Nix build environment"
                echo "HOME: $HOME"
                echo "TMPDIR: $TMPDIR"
                echo "CLJ_CONFIG: $CLJ_CONFIG"
                echo "CLJ_CACHE: $CLJ_CACHE"
                echo "GITLIBS: $GITLIBS"
                echo "JAVA_TOOL_OPTIONS: $JAVA_TOOL_OPTIONS"
                echo "==> Current Directory:"
                pwd
                echo "==> Directory Contents:"
                ls -la

                # Run your build command
                echo "about to run `clj` commands!"
                which clojure
                echo "clojure --version"
                clojure --version
                echo "clj -Sdescribe"
                clojure -Sdescribe
                echo "clojure -Spath ..."
                # All variants of this fail
                clojure -Spath
                clojure -Sdeps '{:deps {org.clojure/clojure {:mvn/version "1.11.3"}} :override-deps {org.clojure/clojure {:mvn/version "1.11.3"}}}' -Sverbose -Spath
                clojure -Sverbose -Sdeps '{:deps {org.clojure/clojure {:mvn/version "1.11.3"}}}' -Spath
                clojure -Sdeps '{:deps {org.clojure/clojure {:mvn/version "1.11.3"}}}' -Sforce -Spath
                clojure -X:deps tree
                clojure -Sverbose -X:build:prod uberjar :build/jar-name "target/clojupyter-standalone.jar"
              '';
            }
          ];
        };
      in kernel.overrideAttrs (old: {
        buildPhase = ''
          echo "Overriden buildPhase"
        '' + old.buildPhase;
        buildInputs = [
          pkgs.which
        ];
      });

      devShells = {
        default = pkgs.devshell.mkShell {
          packages = [
            pkgs.nodejs_23
            pkgs.clojure
            pkgs.zulu23
          ];
          commands = [
            {
              help = "Run clj-nix";
              name = "clj-nix-deps-lock";
              command = ''
                  nix run github:jlesquembre/clj-nix#deps-lock
                '';
            }
            {
              help = "Build jar normally";
              name = "clj-build";
              command = ''
                  clojure -X:build:prod uberjar :build/jar-name "target/clojupyter-standalone.jar"
                '';
            }
          ];
        };
      };
    });
}
