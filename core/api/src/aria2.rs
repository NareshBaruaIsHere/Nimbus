use std::process::{Command, Child};
use std::sync::Mutex;

pub struct Aria2Manager {
    process: Mutex<Option<Child>>,
}

impl Aria2Manager {
    pub fn new() -> Self {
        Self {
            process: Mutex::new(None),
        }
    }

    pub fn start(&self) -> Result<(), String> {
        let mut process_lock = self.process.lock().unwrap();
        
        if process_lock.is_some() {
            return Ok(()); // Already running
        }

        // Assuming aria2c is in the system PATH or alongside the executable
        let child = Command::new("aria2c")
            .arg("--enable-rpc")
            .arg("--rpc-listen-all=false")
            .arg("--rpc-listen-port=6800")
            .arg("--max-concurrent-downloads=16")
            .arg("--split=16")
            .arg("--max-connection-per-server=16")
            .spawn()
            .map_err(|e| format!("Failed to start aria2c: {}", e))?;

        *process_lock = Some(child);
        println!("Started aria2c process.");
        
        Ok(())
    }

    pub fn stop(&self) {
        let mut process_lock = self.process.lock().unwrap();
        if let Some(mut child) = process_lock.take() {
            println!("Stopping aria2c process...");
            let _ = child.kill();
            let _ = child.wait();
        }
    }
}

impl Drop for Aria2Manager {
    fn drop(&mut self) {
        self.stop();
    }
}
