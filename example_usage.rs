// Example of how to use the generated Rust protobuf types
// Add this to your Cargo.toml:
// [dependencies]
// session-protobuf-types = { path = "./generated/rust" }

use session_protobuf_types::{ColorProto, PointProto, Message};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🦀 Testing Rust protobuf types...");

    // Create a color
    let color = ColorProto {
        name: "Bright Red".to_string(),
        guid: "color-001".to_string(),
        r: 255,
        g: 0,
        b: 0,
        a: 255,
    };

    // Create a point with the color
    let point = PointProto {
        guid: "point-001".to_string(),
        name: "Origin Point".to_string(),
        x: 10.5,
        y: 20.3,
        z: 30.7,
        width: 2.5,
        pointcolor: Some(color.clone()),
    };

    // Serialize to bytes (this is cross-platform compatible)
    let serialized_bytes = point.encode_to_vec();
    println!("✅ Serialized point to {} bytes", serialized_bytes.len());

    // Deserialize from bytes
    let deserialized_point = PointProto::decode(&serialized_bytes[..])?;
    println!("✅ Deserialized point: '{}'", deserialized_point.name);
    println!("   Position: ({}, {}, {})", 
             deserialized_point.x, 
             deserialized_point.y, 
             deserialized_point.z);
    
    if let Some(point_color) = &deserialized_point.pointcolor {
        println!("   Color: '{}' RGB({}, {}, {})", 
                 point_color.name,
                 point_color.r, 
                 point_color.g, 
                 point_color.b);
    }

    // The bytes can be shared with C++ and Python using the same proto files!
    println!("🌍 These bytes are compatible with C++ and Python versions!");

    Ok(())
}
