mod api;
mod aria2;

use std::net::SocketAddr;
use std::sync::Arc;
use tokio::net::TcpListener;

#[tokio::main]
async fn main() {
    println!("Starting Nimbus Local Backend...");

    // Start aria2c process manager
    let aria2_manager = Arc::new(aria2::Aria2Manager::new());
    if let Err(e) = aria2_manager.start() {
        eprintln!("Warning: Failed to start aria2c natively: {}", e);
        eprintln!("Make sure aria2c is in your PATH. We will still run the API server.");
    }

    // Set up Axum API router
    let app = api::create_router();

    // Bind and serve
    let addr = SocketAddr::from(([127, 0, 0, 1], 4578));
    println!("Listening on http://{}", addr);

    let listener = TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
