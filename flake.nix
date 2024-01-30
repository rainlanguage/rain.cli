{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    rainix.url = "github:rainprotocol/rainix";
  };

  outputs = { self, flake-utils, rainix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = rainix.pkgs.${system};
      in rec {
        packages = {
          rain = (pkgs.makeRustPlatform{
            rustc = rainix.rust-toolchain.${system};
            cargo = rainix.rust-toolchain.${system};
          }).buildRustPackage {
            src = ./.;
            doCheck = false;
            name = "rain";
            cargoLock.lockFile = ./Cargo.lock;
            # allows for git deps to be resolved without the need to specify their outputHash
            cargoLock.allowBuiltinFetchGit = true;
            buildPhase = ''
              cargo build --release --bin rain
            '';
            installPhase = ''
              mkdir -p $out/bin
              cp target/release/rain $out/bin/
            '';
            buildInputs = rainix.rust-build-inputs.${system};
            nativeBuildInputs = rainix.rust-build-inputs.${system};
          };
        } // rainix.packages.${system};

        defaultPackage = packages.rain;

        devShells = rainix.devShells.${system};
      }
    );
}
