{ pkgs ? import
    (builtins.fetchTarball {
      name = "nixos-unstable-2023-04-19";
      url = "https://github.com/nixos/nixpkgs/archive/bb2009ca185d97813e75736c2b8d1d8bb81bde05.tar.gz";
      sha256 = "sha256:003qcrsq5g5lggfrpq31gcvj82lb065xvr7bpfa8ddsw8x4dnysk";
    })
    { } }:
let

in
pkgs.stdenv.mkDerivation {
  name = "shell";
  buildInputs = [
    pkgs.cargo
    pkgs.iconv
    pkgs.gmp
  ] ++ (pkgs.lib.optionals pkgs.stdenv.isDarwin [
    pkgs.darwin.apple_sdk.frameworks.Security
    pkgs.darwin.apple_sdk.frameworks.CoreFoundation
    pkgs.darwin.apple_sdk.frameworks.CoreServices
  ]);

  shellHook = ''
  export PATH="$PATH":~/.cargo/bin
  '';
}
