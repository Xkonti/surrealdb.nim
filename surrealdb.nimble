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
    # CBOR
    "test_cbor_reader.nim",
    "test_cbor_writer.nim",

    "test_cbor_decoder_arrays.nim",
    "test_cbor_decoder_bool.nim",
    "test_cbor_decoder_bytes.nim",
    "test_cbor_decoder_integers.nim",
    "test_cbor_decoder_objects.nim",
    "test_cbor_decoder_strings.nim",

    "test_cbor_encoder_head.nim",
    "test_cbor_encoder_arrays.nim",
    "test_cbor_encoder_bool.nim",
    "test_cbor_encoder_bytes.nim",
    "test_cbor_encoder_integers.nim",
    "test_cbor_encoder_objects.nim",
    "test_cbor_encoder_strings.nim",

    "test_cbor_encoding.nim",

    # SurrealValue
    "test_surrealvalue_array.nim",
    "test_surrealvalue_bool.nim",
    "test_surrealvalue_bytes.nim",
    "test_surrealvalue_integer.nim",
    "test_surrealvalue_object.nim",
    "test_surrealvalue_string.nim"
  ]:
    exec "nim r --hints:off tests/" & file
  