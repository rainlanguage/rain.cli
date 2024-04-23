{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    rainix.url = "github:rainprotocol/rainix/6097a125b4ab515e650a6f35d6018744c4ac3bc4";
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
              set -euxo pipefail
              echo ${pkgs.libusb}
              echo $PKG_CONFIG_PATH
              pkg-config --list-all
              pkg-config libusb-1.0 --libs
              sw_vers -productVersion

              cd lib/rain.metadata
              RUST_LOG=trace forge build --force --cache-path "`pwd`/cache" --out "`pwd`/out" --root `pwd` --offline --use ${pkgs.solc_0_8_19}/bin/solc-0.8.19
              cd -
              LIBUSB_STATIC=0 cargo build --release --bin rain
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
