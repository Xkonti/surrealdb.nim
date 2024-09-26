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
    "surrealvalue/test_surrealvalue_integer.nim",
    "surrealvalue/test_surrealvalue_none.nim",
    "surrealvalue/test_surrealvalue_null.nim",
    "surrealvalue/test_surrealvalue_object.nim",
    "surrealvalue/test_surrealvalue_string.nim",

    # CBOR
    "cbor/test_cbor_reader.nim",
    "cbor/test_cbor_writer.nim",

    "cbor/decoding/test_cbor_decoder_arrays.nim",
    "cbor/decoding/test_cbor_decoder_bool.nim",
    "cbor/decoding/test_cbor_decoder_bytes.nim",
    "cbor/decoding/test_cbor_decoder_integers.nim",
    "cbor/decoding/test_cbor_decoder_null.nim",
    "cbor/decoding/test_cbor_decoder_objects.nim",
    "cbor/decoding/test_cbor_decoder_strings.nim",

    "cbor/encoding/test_cbor_encoder_head.nim",
    "cbor/encoding/test_cbor_encoder_arrays.nim",
    "cbor/encoding/test_cbor_encoder_bool.nim",
    "cbor/encoding/test_cbor_encoder_bytes.nim",
    "cbor/encoding/test_cbor_encoder_integers.nim",
    # "cbor/encoding/test_cbor_encoder_none.nim",
    "cbor/encoding/test_cbor_encoder_null.nim",
    "cbor/encoding/test_cbor_encoder_objects.nim",
    "cbor/encoding/test_cbor_encoder_strings.nim",

    "cbor/test_cbor_encoding.nim"
  ]:
    exec "nim r --hints:off tests/" & file
  