use std::env;
use std::path::PathBuf;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let out_dir = PathBuf::from(env::var("OUT_DIR").unwrap());
    
    // Configure prost-build
    prost_build::Config::new()
        .out_dir(&out_dir)
        .compile_protos(
            &[
                "../../proto/color.proto",
                "../../proto/point.proto",
            ],
            &[
                "../../proto/",
            ],
        )?;
    
    println!("cargo:rerun-if-changed=../../proto/");
    Ok(())
}
