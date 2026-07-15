use axum::{
    routing::{get, post},
    Router,
    Json,
};
use serde::{Deserialize, Serialize};

#[derive(Deserialize)]
pub struct DownloadRequest {
    pub url: String,
    pub category: Option<String>,
    pub dir: Option<String>,
}

#[derive(Serialize)]
pub struct StatusResponse {
    pub status: String,
    pub message: String,
}

pub fn create_router() -> Router {
    Router::new()
        .route("/download", post(handle_download))
        .route("/status", get(handle_status))
}

async fn handle_download(Json(payload): Json<DownloadRequest>) -> Json<StatusResponse> {
    // In the future, this will send an RPC request to aria2c to add the download.
    println!("Received download request for: {}", payload.url);
    
    Json(StatusResponse {
        status: "success".to_string(),
        message: format!("Queued {}", payload.url),
    })
}

async fn handle_status() -> Json<StatusResponse> {
    Json(StatusResponse {
        status: "success".to_string(),
        message: "Nimbus Backend is running".to_string(),
    })
}
