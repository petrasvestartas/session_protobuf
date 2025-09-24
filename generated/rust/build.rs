use std::env;
use std::path::PathBuf;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let out_dir = PathBuf::from(env::var("OUT_DIR").unwrap());
    
    // Configure prost-build to use protoc-bin-vendored
    prost_build::Config::new()
        .protoc_arg("--experimental_allow_proto3_optional")
        .out_dir(&out_dir)
        .compile_protos(
            &[
                "proto/color.proto",
                "proto/point.proto",
            ],
            &[
                "proto/",
            ],
        )?;
    
    println!("cargo:rerun-if-changed=proto/");
    Ok(())
}
