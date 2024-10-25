# Package

version       = "0.1.0"
author        = "Xkonti"
description   = "SurrealDB driver for Nim"
license       = "MIT"
srcDir        = "src"
bin           = @["surrealdb"]


# Dependencies

requires "nim >= 2.0.0"
requires "ws"
requires "tinyre"

# Test dependencies

requires "asynctest >= 0.5.2 & < 0.6.0"
requires "dotenv >= 2.0.0"


# Docs generation task
task docs, "Write the package docs":
  exec "nim doc --verbosity:0 --project --index:on " &
    "--git.url:https://github.com/Xkonti/surrealdb.nim" &
    "--git.commit:master " &
    "-o:docs " &
    "src/surrealdb"

task test_surreal, "Tests agains SurrealDB instance":
  for file in ["test_basics.nim"]:
    exec "nim r --hints:off tests/" & file

task test, "General tests":
  for file in [
    # SurrealValue
    "surrealvalue/test_surrealvalue_array.nim",
    "surrealvalue/test_surrealvalue_bool.nim",
    "surrealvalue/test_surrealvalue_bytes.nim",
    "surrealvalue/test_surrealvalue_datetime.nim",
    "surrealvalue/test_surrealvalue_duration.nim",
    "surrealvalue/test_surrealvalue_float.nim",
    "surrealvalue/test_surrealvalue_future.nim",
    "surrealvalue/test_surrealvalue_integer.nim",
    "surrealvalue/test_surrealvalue_none.nim",
    "surrealvalue/test_surrealvalue_null.nim",
    "surrealvalue/test_surrealvalue_object.nim",
    "surrealvalue/test_surrealvalue_recordid.nim",
    "surrealvalue/test_surrealvalue_string.nim",
    "surrealvalue/test_surrealvalue_table.nim",
    "surrealvalue/test_surrealvalue_uuid.nim",

    # CBOR
    "cbor/test_cbor_reader.nim",
    "cbor/test_cbor_writer.nim",

    "cbor/encoding/test_cbor_encoder_head.nim",
    "cbor/encoding/test_cbor_encoder_array.nim",
    "cbor/encoding/test_cbor_encoder_bool.nim",
    "cbor/encoding/test_cbor_encoder_bytes.nim",
    "cbor/encoding/test_cbor_encoder_datetime.nim",
    "cbor/encoding/test_cbor_encoder_duration.nim",
    "cbor/encoding/test_cbor_encoder_float.nim",
    "cbor/encoding/test_cbor_encoder_future.nim",
    "cbor/encoding/test_cbor_encoder_integer.nim",
    "cbor/encoding/test_cbor_encoder_none.nim",
    "cbor/encoding/test_cbor_encoder_null.nim",
    "cbor/encoding/test_cbor_encoder_object.nim",
    "cbor/encoding/test_cbor_encoder_record.nim",
    "cbor/encoding/test_cbor_encoder_string.nim",
    "cbor/encoding/test_cbor_encoder_table.nim",
    "cbor/encoding/test_cbor_encoder_uuid.nim",

    "cbor/decoding/test_cbor_decoder_array.nim",
    "cbor/decoding/test_cbor_decoder_bool.nim",
    "cbor/decoding/test_cbor_decoder_bytes.nim",
    "cbor/decoding/test_cbor_decoder_datetime.nim", 
    "cbor/decoding/test_cbor_decoder_duration.nim", 
    "cbor/decoding/test_cbor_decoder_float.nim",
    "cbor/decoding/test_cbor_decoder_future.nim",
    "cbor/decoding/test_cbor_decoder_integer.nim",
    "cbor/decoding/test_cbor_decoder_null.nim",
    "cbor/decoding/test_cbor_decoder_none.nim",
    "cbor/decoding/test_cbor_decoder_object.nim",
    "cbor/decoding/test_cbor_decoder_record.nim",
    "cbor/decoding/test_cbor_decoder_string.nim",
    "cbor/decoding/test_cbor_decoder_table.nim",
    "cbor/decoding/test_cbor_decoder_uuid.nim",

    "cbor/test_cbor_encoding.nim"
  ]:
    exec "nim r --hints:off tests/" & file
  
