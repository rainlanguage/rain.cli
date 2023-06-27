use anyhow::Result;
use clap::command;
use clap::{Parser, Subcommand};
use rain_cli_ob;
use rain_cli_meta;

/// Rain CLI.
/// Base struct just wraps subcommands so that we can dispatch to dependencies.
#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Cli {
    #[command(subcommand)]
    namespace: Namespace,
}

/// Namespace represents each dependency, which is itself an entire CLI.
#[derive(Subcommand)]
enum Namespace {
    #[command(subcommand)]
    Orderbook(rain_cli_ob::cli::Orderbook),
    #[command(subcommand)]
    Meta(rain_cli_meta::cli::Meta),
}

#[tokio::main]
async fn main() -> Result<()> {
    tracing::subscriber::set_global_default(tracing_subscriber::fmt::Subscriber::new())?;

    let cli = Cli::parse();
    match cli.namespace {
        Namespace::Orderbook(orderbook) => rain_cli_ob::cli::dispatch(orderbook).await,
        Namespace::Meta(meta) => rain_cli_meta::cli::dispatch(meta),
    }
}