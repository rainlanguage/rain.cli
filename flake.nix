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
            # submodules = true;
            buildPhase = ''
              # mkdir -p $out/lib
              # cp -r lib $out/lib
              # ls -la
              # ls -la lib
              # cd lib/rain.metadata
              # mkdir -p $out/cache
              # mkdir -p $out/out
              set -euxo pipefail
              # echo "$src"
              # ls -la "$src"
              # ls -la "$src/lib/rain.metadata"
              # whoami
              # sudo mkdir -p "$src/out"
              # forge build --force --root "$src/lib/rain.metadata" --out $src/out
              # cd -
              echo $CARGO_TARGET_DIR
              cargo build --release --bin rain
            '';
            installPhase = ''
              mkdir -p $out/bin
              cp target/release/rain $out/bin/
            '';
            buildInputs = rainix.rust-build-inputs.${system} ++ rainix.sol-build-inputs.${system};
            nativeBuildInputs = rainix.rust-build-inputs.${system} ++ rainix.sol-build-inputs.${system};
          };
        } // rainix.packages.${system};

        defaultPackage = packages.rain;

        devShells = rainix.devShells.${system};
      }
    );
}
