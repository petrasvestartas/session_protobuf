//! Generated Protocol Buffer types
//! 
//! This crate provides Rust bindings for protobuf serialization.
//! The protobuf dependency is minimal (runtime only).

#![allow(unused_imports)]
#![allow(clippy::all)]

// Include generated protobuf modules
include!(concat!(env!("OUT_DIR"), "/protos/mod.rs"));

// Re-export commonly used types
pub use protobuf::*;
