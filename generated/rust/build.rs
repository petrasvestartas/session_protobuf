use protobuf_codegen::Codegen;
use std::path::Path;

fn main() {
    println!("cargo:rerun-if-changed=proto/");
    
    let mut codegen = Codegen::new()
        .pure()
        .cargo_out_dir("protos");

    // Google well-known types
    codegen = codegen.input("../../src/src/google/protobuf/any.proto");
    codegen = codegen.input("../../src/src/google/protobuf/timestamp.proto");
    codegen = codegen.input("../../src/src/google/protobuf/duration.proto");
    codegen = codegen.input("../../src/src/google/protobuf/empty.proto");
    codegen = codegen.input("../../src/src/google/protobuf/struct.proto");
    codegen = codegen.input("../../src/src/google/protobuf/wrappers.proto");
    // User proto files
    codegen = codegen.input("../../proto/user/point.proto");
    codegen = codegen.input("../../proto/user/color.proto");

    codegen
        .include("../../src/src")
        .include("../../proto")
        .run_from_script();
}
