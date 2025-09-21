# Common Protocol Buffer Definitions

This directory contains commonly used `.proto` files that are included in releases.

## Included Files

### Google Well-Known Types
- `google/protobuf/any.proto` - Any message type
- `google/protobuf/timestamp.proto` - Timestamp representation
- `google/protobuf/duration.proto` - Duration representation
- `google/protobuf/empty.proto` - Empty message
- `google/protobuf/struct.proto` - JSON-like structures
- `google/protobuf/wrappers.proto` - Wrapper types for primitives

### Usage
These files are automatically available when you use the protobuf installation from this release.

```bash
# Example usage
protoc --cpp_out=. --proto_path=proto your_file.proto
```
