# rain.cli

The Rain CLI.

Aggregates and compiles all the other Rain CLI tools into a single tool.

Doesn't provide any of its own functionality.

## Installation

### Nix flakes

If you have https://nixos.org/ installed and nix flakes enabled https://nixos.wiki/wiki/Flakes
then you can run the Rain CLI straight from github.

```
nix shell github:rainprotocol/rain.cli -c rain
```

This will track the default branch (main) and can be aliased e.g.

```
alias rain="nix shell github:rainprotocol/rain.cli -c rain"
```

If you add this alias to your ~/.bashrc or ~/.zshrc file, etc. then you'll always
have fresh `rain`.

You can also pin it to any git revision like

```
nix shell github:rainprotocol/rain.cli/<revision> -c rain
```

Alternatively you can install it to your profile and nix can manage it like any
other binary.

```
nix profile install github:rainprotocol/rain.cli
```

### Cargo

Rain CLI is written in Rust so can be installed with `cargo` like any other Rust
binary.

From this repo at any commit

```
cargo install --path .
```

From crates.io

```
cargo install rain_cli
```

This approach will compile and save the `rain` binary at `~/.cargo/bin` which
means:

- You need to make sure that `~/.cargo/bin` is on your `$PATH`
- You are responsible for tracking versions and/or uninstalling via cargo ongoing