//! Generated Protocol Buffer types using prost
//! 
//! This crate provides Rust bindings for protobuf serialization using prost.

#![allow(unused_imports)]
#![allow(clippy::all)]

pub use prost::Message;

// Include generated protobuf modules from build.rs
include!(concat!(env!("OUT_DIR"), "/session_proto.color.rs"));
include!(concat!(env!("OUT_DIR"), "/session_proto.point.rs"));

// Re-export the main types for convenience
pub use color_proto::ColorProto;
pub use point_proto::PointProto;
