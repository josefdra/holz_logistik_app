use std::collections::HashMap;
use std::sync::{Arc, Mutex};
use warp::ws::{Message, WebSocket};
use warp::Filter;
use futures_util::{SinkExt, StreamExt};
use tokio::sync::mpsc;
use tokio::sync::mpsc::UnboundedSender;
use serde_json::{Value, json};
use std::env;

// Client connection with an ID and a sender
#[derive(Debug)]
struct Client {
    sender: UnboundedSender<Message>,
}

// Shared state between all clients
type Clients = Arc<Mutex<HashMap<String, Client>>>;

#[tokio::main]
async fn main() {
    // Set default port or use environment variable
    let port = env::var("PORT").unwrap_or_else(|_| "8080".to_string());
    let port: u16 = port.parse().expect("PORT must be a number");
    
    // Store connected clients
    let clients: Clients = Arc::new(Mutex::new(HashMap::new()));
    
    // Log the server start
    println!("Starting WebSocket server on port {}...", port);
    
    // WebSocket route
    let ws_route = warp::path("ws")
        .and(warp::ws())
        .and(with_clients(clients.clone()))
        .map(|ws: warp::ws::Ws, clients| {
            ws.on_upgrade(move |socket| handle_connection(socket, clients))
        });
    
    // Health check route
    let health_route = warp::path::end().map(|| "User Sync WebSocket Server is running.");
    
    let routes = ws_route.or(health_route);
    
    warp::serve(routes).run(([0, 0, 0, 0], port)).await;
}

// Utility function to pass clients to the route
fn with_clients(clients: Clients) -> impl Filter<Extract = (Clients,), Error = std::convert::Infallible> + Clone {
    warp::any().map(move || clients.clone())
}

// Handle a new WebSocket connection
async fn handle_connection(ws: WebSocket, clients: Clients) {
    let (mut ws_tx, mut ws_rx) = ws.split();
    
    // Use a channel to handle outgoing messages
    let (tx, mut rx) = mpsc::unbounded_channel();
    
    // Generate client id
    let client_id = format!("client-{}", uuid::Uuid::new_v4());
    
    // Add the client to our map
    clients.lock().unwrap().insert(client_id.clone(), Client { sender: tx });
    
    println!("New client connected: {}", client_id);
    
    // Spawn a task for sending messages
    tokio::task::spawn(async move {
        while let Some(message) = rx.recv().await {
            if let Err(e) = ws_tx.send(message).await {
                println!("Error sending WebSocket message: {:?}", e);
                break;
            }
        }
    });
    
    // Handle incoming messages
    while let Some(result) = ws_rx.next().await {
        match result {
            Ok(msg) => {
                // Skip if not a text message
                if !msg.is_text() {
                    continue;
                }
                
                // Try to parse the message as JSON
                if let Ok(text) = msg.to_str() {
                    if let Ok(json_msg) = serde_json::from_str::<Value>(text) {
                        handle_client_message(client_id.clone(), json_msg, &clients).await;
                    }
                }
            }
            Err(e) => {
                println!("WebSocket error: {:?}", e);
                break;
            }
        }
    }
    
    // Client disconnected
    clients.lock().unwrap().remove(&client_id);
    println!("Client disconnected: {}", client_id);
}

// Handle a message from a client
async fn handle_client_message(client_id: String, msg: Value, clients: &Clients) {
    // Extract message type and data
    let msg_type = msg.get("type").and_then(|v| v.as_str()).unwrap_or("unknown");
    
    println!("Received {} message from {}", msg_type, client_id);
    
    // For user_update messages, broadcast to all other clients
    if msg_type == "user_update" {
        // Create a new message with timestamp
        let data = msg.get("data").cloned().unwrap_or(json!({}));
        let timestamp = msg.get("timestamp").cloned().unwrap_or(json!(chrono::Utc::now().to_rfc3339()));
        
        let broadcast_msg = json!({
            "type": "user_update",
            "data": data,
            "timestamp": timestamp
        });
        
        let serialized = serde_json::to_string(&broadcast_msg).unwrap();
        
        // Broadcast to all clients except the sender
        let clients_lock = clients.lock().unwrap();
        for (id, client) in clients_lock.iter() {
            if id != &client_id {
                if let Err(e) = client.sender.send(Message::text(&serialized)) {
                    println!("Error sending message to client {}: {:?}", id, e);
                }
            }
        }
        
        println!("Broadcasted user_update to all other clients");
    }
}