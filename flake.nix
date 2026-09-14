{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    rainix.url = "github:rainlanguage/rainix";
  };

  outputs =
    {
      flake-utils,
      rainix,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = rainix.pkgs.${system};
      in
      rec {
        packages = rec {
          rain =
            (pkgs.makeRustPlatform {
              rustc = rainix.rust-toolchain.${system};
              cargo = rainix.rust-toolchain.${system};
            }).buildRustPackage
              {
                src = ./.;
                doCheck = false;
                name = "rain";
                # importCargoLock fetches each crate from crates.io/api, which
                # answers 403 to any User-Agent starting with curl/, and that is
                # what nixpkgs fetchurl sends. Hand it a fetchurl that overrides
                # the agent; the fixed-output hashes are unchanged so cache hits
                # are too. Not fetchCargoVendor: its hash covers Cargo.lock, so the
                # release version bump would break every build until re-hashed.
                cargoDeps =
                  (pkgs.callPackage (pkgs.path + "/pkgs/build-support/rust/import-cargo-lock.nix") {
                    cargo = rainix.rust-toolchain.${system};
                    fetchurl = args: pkgs.fetchurl (args // { curlOptsList = (args.curlOptsList or [ ]) ++ [ "--user-agent" "Nixpkgs" ]; });
                  })
                    {
                      lockFile = ./Cargo.lock;
                      allowBuiltinFetchGit = true;
                    };
                buildInputs = rainix.rust-build-inputs.${system};
                nativeBuildInputs = rainix.rust-build-inputs.${system};
              };
        }
        // rainix.packages.${system};

        defaultPackage = packages.rain;

        devShells.default = pkgs.mkShell {
          packages = [
            packages.rain
          ];

          inherit (rainix.devShells.${system}.default) shellHook buildInputs nativeBuildInputs;
        };
      }
    );
}
