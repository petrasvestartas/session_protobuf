//! Test binary for generated protobuf types

use session_protobuf_types::{ColorProto, PointProto, Message};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🦀 Testing generated protobuf types...");

    // Create a color
    let color = ColorProto {
        name: "Test Red".to_string(),
        guid: "color-test".to_string(),
        r: 255,
        g: 0,
        b: 0,
        a: 255,
    };

    // Create a point with the color
    let point = PointProto {
        guid: "point-test".to_string(),
        name: "Test Point".to_string(),
        x: 1.0,
        y: 2.0,
        z: 3.0,
        width: 1.5,
        pointcolor: Some(color),
    };

    // Test serialization
    let bytes = point.encode_to_vec();
    println!("✅ Serialized {} bytes", bytes.len());

    // Test deserialization
    let decoded = PointProto::decode(&bytes[..])?;
    println!("✅ Deserialized point: '{}'", decoded.name);

    println!("🎉 All tests passed! Rust protobuf types are working correctly.");
    Ok(())
}
