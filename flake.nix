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
                # Vendored through fetchCargoVendor rather than cargoLock: cargoLock
                # fetches each crate from crates.io/api, which answers 403 to the
                # curl User-Agent nix sends, so any store miss fails the build.
                # fetchCargoVendor pulls from the static.crates.io CDN.
                cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
                  src = ./.;
                  name = "rain";
                  hash = "sha256-TrZzMmDnC07lhfjKdKfwNtrzbeRcxKewqTqmiZD2fic=";
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
