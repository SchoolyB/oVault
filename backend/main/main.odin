package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:time"
import "../src/server"
import "core:slice"
import lib"../src/library"
/*
Copyright (c) 2025-Present Marshall A. Burns

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

main ::proc(){
    using lib
    using fmt
    using server

    config:= create_custom_config()
    server:= create_custom_server(config)

    init_database()


    // Run the server
    serve(server)
}

create_custom_config :: proc() -> lib.Config {
    using lib

    //Make a new config to be passed to the server
    config := new(Config)

    //General config information. Modify discretion

    config :Config
    config.port = 8080 //If you modify this, update the port in HANDLE_SERVER_KILL_SWITCH() in server.odin
    config.host = strings.clone("localhost")
    config.bindAddress =  strings.clone("127.0.0.1")
    config.apiVersion = strings.clone("v1")
    config.backlogSize  = 3
    config.maxConnections = 1

    //Security config information. Modify discretion
    config.security.maxRequestBodySizeMb = 5

    //CORS config information. Modify discretion
    allowedOrigins:[]string={"http://localhost:8080"}
    config.cors.allowedOrigins = slice.clone(allowedOrigins)

    allowedMethods:[]lib.HttpMethod = slice.clone(validMethods)
    config.cors.allowedMethods =  allowedMethods


    allowedHeaders :[]string= {"Content-Type","Authorization", "authorization", "X-Requested-With", "X-API-Key"}
    config.cors.allowedHeaders = slice.clone(allowedHeaders)
    config.cors.exposeHeaders = slice.clone([]string{"X-Project-Id", "X-Resource-Count"})
    config.cors.maxAgeSeconds = 86400
    config.cors.allowCredentials = true

    return config
}


create_custom_server :: proc(config: lib.Config) -> ^lib.Server{
    using fmt
    using lib

    //Make a new server
    server := new(lib.Server)

    serverVersion:= "v0.1.0" //Modify this if you so choose
    apiBase:= tprintf("/api/%s", config.apiVersion)


    server.startTimestamp = time.now()
    server.version = serverVersion
    server.apiBase = strings.clone(apiBase)
    server.config = config

    return server
}