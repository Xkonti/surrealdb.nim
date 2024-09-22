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