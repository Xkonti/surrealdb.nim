## This is a basic test file for SurrealDB driver.
## It tests the basic functionality of the SurrealDB driver.

import std/[asyncdispatch, json, os]
import asynctest/asyncdispatch/unittest
import dotenv

import surrealdb

template connectToSurrealDB(surreal: untyped, url: string): untyped =
    var surreal: SurrealDB
    try:
        surreal = await newSurrealDbConnection(surrealUrl)
        assert surreal != nil, "Couldn't connect to SurrealDB"
    except CatchableError:
        assert false, "Couldn't connect to SurrealDB"
    defer: surreal.disconnect()

suite "basics":
    var surrealUrl: string
    var rootPass: string
    var rootUser: string

    setup:
        load() # Load environment variables from .env file
        surrealUrl = getEnv("TESTING_SURREAL_URL")
        rootUser = getEnv("TESTING_SURREAL_ROOT_USER")
        rootPass = getEnv("TESTING_SURREAL_ROOT_PASS")
        assert surrealUrl.len > 0, "TESTING_SURREAL_URL environment variable is not set"
        assert rootUser.len > 0, "TESTING_SURREAL_ROOT_USER environment variable is not set"
        assert rootPass.len > 0, "TESTING_SURREAL_ROOT_PASS environment variable is not set"

    test "Tests work":
        assert true

    test "can connect to SurrealDB":
        try:
            let surreal = await newSurrealDbConnection(surrealUrl)
            assert surreal != nil, "Couldn't connect to SurrealDB"
            defer: surreal.disconnect()
        except CatchableError:
            assert false, "Couldn't connect to SurrealDB"

    # Having trouble making this run in tests
    # test "can use the database":
    #     var surreal: SurrealDB
    #     try:
    #         surreal = await newSurrealDbConnection(surrealUrl)
    #         assert surreal != nil, "Couldn't connect to SurrealDB"
    #     except CatchableError:
    #         assert false, "Couldn't connect to SurrealDB"
    #     defer: surreal.disconnect()

    #     # Switch to the test database
    #     let ns = "test"
    #     let db = "test"
    #     let useResponse = await surreal.use(ns, db)
    #     assert useResponse.isOk, "Use error: " & useResponse.error.message

    #     # Sign in as root user
    #     let signinResponse = await surreal.signin(rootUser, rootPass)
    #     assert signinResponse.isOk, "Signin error: " & signinResponse.error.message

    #     # Query the database
    #     let queryResponse = await surreal.query("RETURN \"Hello!\"".SurQL)
    #     assert queryResponse.isOk, "Query error: " & queryResponse.error.message
    #     assert queryResponse.ok[0]["result"].getStr() == "Hello!"
