package server

import "core:fmt"
import "core:net"
import "core:os"
import "core:time"
import "core:c/libc"
import "core:thread"
import "core:strings"
import "core:strconv"
import "core:slice"
import lib "../library"
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
@(private)
serverIsRunning:= false

@(private)
router := make_new_router()

serve :: proc(server: ^lib.Server) -> lib.Error {
    using lib
    using fmt

    serverIsRunning = true

    { //START OF TEMP CONTEXT ALLOCATION SCOPE
            context.allocator = context.temp_allocator

            //CORS shit
            pingCorsRoute:= make_new_route(.OPTIONS, fmt.tprintf("%s%s", server.apiBase, "/ping"), handle_options_request)
            healthCorsRoute:= make_new_route(.OPTIONS, fmt.tprintf("%s%s", server.apiBase, "/health"), handle_options_request)
            dynAuthCorsRoute:=make_new_route(.OPTIONS,tprintf("%s/auth/*", server.apiBase), handle_options_request)
            dynEntryCorsRoute:= make_new_route(.OPTIONS,tprintf("%s/entry/*", server.apiBase), handle_options_request)

            //Simple server health check routes
            pingGetRoute := make_new_route(.GET, fmt.tprintf("%s%s", server.apiBase, "/ping"), handle_get_request)
            healthGetRoute:= make_new_route(.GET, fmt.tprintf("%s%s", server.apiBase, "/health"), handle_get_request)

            //Auth routes
            authLoginPostRoute:= make_new_route(.POST,tprintf("%s/auth%s", server.apiBase, "/login") ,handle_post_request)
            authRegisterPostRoute:= make_new_route(.POST,tprintf("%s/auth%s", server.apiBase, "/register") ,handle_post_request)

            //Account enrtry managment routes
            newEntryPostRoute := make_new_route(.POST,tprintf("%s/entry%s", server.apiBase, "/new") ,handle_post_request)
            removeEntryDeleteRoute := make_new_route(.DELETE,tprintf("%s/entry%s", server.apiBase, "/remove") ,handle_post_request)
            renameEntryPutRoute := make_new_route(.PUT,tprintf("%s/entry%s", server.apiBase, "/rename") ,handle_post_request)
            updateUsernameEntryPutRoute := make_new_route(.PUT,tprintf("%s/entry%s", server.apiBase, "/update_username") ,handle_post_request)
            updatePasswordEntryPutRoute := make_new_route(.PUT,tprintf("%s/entry%s", server.apiBase, "/update_password") ,handle_post_request)



            routeArray:=make([dynamic]^lib.Route)

            append(&routeArray, pingCorsRoute)
            append(&routeArray, healthCorsRoute)
            append(&routeArray, pingGetRoute)
            append(&routeArray, pingGetRoute)
            append(&routeArray, authLoginPostRoute)
            append(&routeArray, authRegisterPostRoute)

            for r in routeArray{
                add_route_to_router(router, r)
            }


    } //END OF TEMP CONTEXT ALLOCATION SCOPE


    bindIP := parse_ip_address("127.0.0.1") //Pass is whatever address you are binding to
    endpoint := net.Endpoint{bindIP, server.config.port}

    listenSocket, listenError := net.listen_tcp(endpoint)
    if listenError != nil {
        printf("Error listening on socket: %v\n", listenError)
        return make_error( "Server Failed To Listen On TCP Socket", .ERROR, get_caller_location())
    }

    defer net.close(net.TCP_Socket(listenSocket))

    printf(
        "Odin HTTP server listening on %s:%d (bind: %s)\n",
        server.config.host,
        server.config.port,
        server.config.bindAddress,
    )

    printf("API Base URL: http://%s:%d%s\n", server.config.host, server.config.port, server.apiBase)

    // Main server loop
    for serverIsRunning {
        fmt.println("Waiting for new connection...")
        clientSocket, remoteEndpoint, acceptError := net.accept_tcp(listenSocket)
        if acceptError != nil {
            fmt.println("Error accepting connection: ", acceptError)
            return make_error("Server Failed To Accept Client TCP Socket Connection", .ERROR, get_caller_location())
        }

        handle_connection(clientSocket, server, router)
    }

    fmt.println("Server stopped successfully")
    return make_error()
}

@(cold)
handle_connection :: proc(socket: net.TCP_Socket, server: ^lib.Server, router: ^lib.Router) -> lib.Error{
    using lib
    using fmt

    defer net.close(socket)

    maxBufferSize := server.config.security.maxRequestBodySizeMb * 1024 * 1024
    buf := make([]byte, min(maxBufferSize, 4096))
    defer delete(buf)

    for {
        println("Waiting to receive data...")
        println("To safely kill the server enter: 'kill' or 'exit' then hit your 'enter' key")

        bytesRead, readTCPSocketError := net.recv(socket, buf[:])

        if bytesRead == 0 {
            println("Connection closed by client")
            return make_error()
        }

        // Parse incoming request
        method, path, headers := parse_http_request(buf[:bytesRead])


        // Extract request body for POST/PUT requests
        request_body := extract_request_body(buf[:bytesRead])
        args := []string{request_body} if len(request_body) > 0 else []string{""}

        // Handle the request using router
        httpStatus, responseBody := handle_http_request(server, router, method, path, headers, args)



        // Build and send response
        responseHeaders := make(map[string]string)
        responseHeaders["Content-Type"] = "application/json"
        responseHeaders["Server"] = tprintf("Odin HTTP Server:%s", server.version)
        responseHeaders["X-API-Version"] = "v1"

        // Apply CORS headers to response
        apply_cors_headers(server, &responseHeaders, headers, method)

        response := build_http_response(httpStatus, responseHeaders, responseBody)

        // Write response to socket
        _, writeError := net.send(socket, response)
        defer delete(response) //TODO: If a memory leak ye seek come here and take a peek - Marshall
        if writeError != nil {
            printf("ERROR: Failed to write response to socket: %v\n", writeError)
            return make_error("Server Failed To Write Response", .ERROR, get_caller_location())
        }
    }
}

// Extract request body from HTTP request
@(require_results)
extract_request_body :: proc(data: []byte) -> string {
    using strings

    lines := split(string(data), "\r\n")
    defer delete(lines)

    // Find empty line that separates headers from body
    bodyStart := -1
    for line, i in lines {
        if len(line) == 0 {
            bodyStart = i + 1
            break
        }
    }

    if bodyStart == -1 || bodyStart >= len(lines) {
        return ""
    }

    // Join remaining lines as body
    bodyLines := lines[bodyStart:]
    body := join(bodyLines, "\r\n")
    return clone(trim_space(body))
}

// // Helper proc to parse IP address strings
@(require_results)
parse_ip_address :: proc(ipString: string) -> net.IP4_Address {
    if ipString == "0.0.0.0" {
        return net.IP4_Address{0, 0, 0, 0}
    }
    if ipString == "127.0.0.1" || ipString == "localhost" {
        return net.IP4_Address{127, 0, 0, 1}
    }

    return net.IP4_Address{0, 0, 0, 0}
}

//Simply waits for a user input to kill server
HANDLE_SERVER_KILL_SWITCH :: proc() {
    using lib
    using fmt
    using strings


	for serverIsRunning {
		input := get_input()
		if input == "kill" || input == "exit" {
			serverIsRunning = false

			//Be sure to change the port number if you use a different server.config.port in main.odin
			portCString := clone_to_cstring("nc -zv localhost 8080")
			libc.system(portCString)

			return
		} else do continue
	}
}