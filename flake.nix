{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    rainix.url = "github:rainlanguage/rainix";
  };

  outputs = { self, flake-utils, rainix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = rainix.pkgs.${system};
      in rec {
        packages = rec {

          rain-metadata-repo = pkgs.stdenv.mkDerivation {
            name = "rain-metadata-repo";
            src = pkgs.fetchgit {
              url = "https://github.com/rainlanguage/rain.metadata";
              rev = "b235fb2d4e4d22e3adda4f316f5a7f21164451fb";
              sha256 = "sha256-LNBoLu4/TPF++17F6STjiJSpEYlfF2B7dbRhIpcT9EA=";
            };
            installPhase = ''
              mkdir -p $out
              cp -r . $out
            '';
          };

          build-cargo-lock = rainix.mkTask.${system} {
            name = "build-cargo-lock";
            body = ''
              rm -rf ./lib/rain.metadata
              mkdir -p ./lib/rain.metadata
              cp --no-preserve=mode,ownership -r ${rain-metadata-repo}/* ./lib/rain.metadata
              cargo generate-lockfile
            '';
          };

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
              mkdir -p lib/rain.metadata
              cp -r ${rain-metadata-repo}/* lib/rain.metadata
              cd lib/rain.metadata
              RUST_LOG=trace forge build --force --cache-path "`pwd`/cache" --out "`pwd`/out" --root `pwd` --offline --use ${pkgs.solc_0_8_19}/bin/solc-0.8.19
              cd -
              cargo build --release --bin rain
            '';
            installPhase = ''
              mkdir -p $out/bin
              cp target/release/rain $out/bin/
            '';
            buildInputs = rainix.rust-build-inputs.${system} ++ rainix.sol-build-inputs.${system};
            nativeBuildInputs = rainix.rust-build-inputs.${system} ++ rainix.sol-build-inputs.${system} ++ [rain-metadata-repo];
          };
        } // rainix.packages.${system};

        defaultPackage = packages.rain;

        devShells.default = pkgs.mkShell {
          packages = [
            packages.rain
            packages.rain-metadata-repo
            packages.build-cargo-lock
          ];

          shellHook = rainix.devShells.${system}.default.shellHook;
          buildInputs = rainix.devShells.${system}.default.buildInputs;
          nativeBuildInputs = rainix.devShells.${system}.default.nativeBuildInputs;
        };
      }
    );
}
