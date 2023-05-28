use anyhow::Result;
use clap::command;
use clap::{Parser, Subcommand};
use rain_cli_ob;

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Cli {
    #[command(subcommand)]
    namespace: Namespace,
}

#[derive(Subcommand)]
enum Namespace {
    #[command(subcommand)]
    Orderbook(rain_cli_ob::cli::Orderbook),
}

#[tokio::main]
async fn main() -> Result<()> {
    tracing::subscriber::set_global_default(tracing_subscriber::fmt::Subscriber::new())?;

    let cli = Cli::parse();
    match cli.namespace {
        Namespace::Orderbook(orderbook) => rain_cli_ob::cli::dispatch(orderbook).await,
    }
}