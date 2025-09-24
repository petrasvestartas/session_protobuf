//! Generated Protocol Buffer types using prost
//! 
//! This crate provides Rust bindings for protobuf serialization using prost.
//! Code generation happens automatically when you build this crate.

#![allow(unused_imports)]
#![allow(clippy::all)]

pub use prost::Message;

// Include generated protobuf code from build.rs
// This file is generated at build time in OUT_DIR
include!(concat!(env!("OUT_DIR"), "/session_proto.rs"));

// The types ColorProto and PointProto are now available directly
