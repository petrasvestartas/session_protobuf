use protobuf_codegen::Codegen;
use std::path::Path;

fn main() {
    println!("cargo:rerun-if-changed=proto/");
    
    let mut codegen = Codegen::new()
        .pure()
        .cargo_out_dir("protos");

    // Main proto files
    codegen = codegen.input("../../proto/color.proto");
    codegen = codegen.input("../../proto/point.proto");

    codegen
        .include("../../install-linux-x86_64/include")
        .include("../../proto")
        .run_from_script();
}
