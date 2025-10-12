package server

import "core:fmt"
import "core:strings"
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

// Apply CORS headers to response
apply_cors_headers :: proc(server: ^lib.Server, headers: ^map[string]string, requestHeaders: map[string]string, method: lib.HttpMethod) {
    using lib
    using fmt
    using strings

    //Get the Origin header from the request
    origin, hasOrigin := requestHeaders["Origin"]

    //Handle file:// protocol (null origin) or missing origin
    if !hasOrigin || origin == "null" || origin == "" {
        headers["Access-Control-Allow-Origin"] = "*"
        headers["Access-Control-Allow-Methods"] = "GET,POST,PUT,DELETE,OPTIONS"
        headers["Access-Control-Allow-Headers"] = "Content-Type,Authorization,X-Requested-With"
        return
    }

    // Load CORS config safely
    corsOptions := make_default_cors_options(server)
    if corsOptions == nil {
        headers["Access-Control-Allow-Origin"] = "*"
        headers["Access-Control-Allow-Methods"] = "GET,POST,PUT,DELETE,OPTIONS"
        headers["Access-Control-Allow-Headers"] = "Content-Type,Authorization,X-Requested-With"
        return
    }
    defer free(corsOptions)

    // Check if the origin is allowed
    isAllowed := false
    for allowedOrigin in corsOptions.allowOrigins {

        if allowedOrigin == "*" || allowedOrigin == origin {
            isAllowed = true
            break
        }

        // Check for wildcard subdomains
        if has_suffix(allowedOrigin, "://*") {
            protocolParts := split(allowedOrigin, "://*")
            if len(protocolParts) > 0 {
                protocol := protocolParts[0]
                expectedPrefix := tprintf("%s://", protocol)
                if has_prefix(origin, expectedPrefix) {
                    isAllowed = true
                    break
                }
            }
        }
    }

    if isAllowed {
        headers["Access-Control-Allow-Origin"] = origin

        if corsOptions.allowCredentials {
            headers["Access-Control-Allow-Credentials"] = "true"
        }

        if method == .OPTIONS {
            // Convert HttpMethod enum to strings
            methodStrings := make([dynamic]string)
            defer delete(methodStrings)

            for httpMethod in corsOptions.allowMethods {
                switch httpMethod {
                case .GET:    append(&methodStrings, "GET")
                case .POST:   append(&methodStrings, "POST")
                case .PUT:    append(&methodStrings, "PUT")
                case .DELETE: append(&methodStrings, "DELETE")
                case .HEAD:   append(&methodStrings, "HEAD")
                case .OPTIONS: append(&methodStrings, "OPTIONS")
                }
            }

            if len(methodStrings) > 0 {
                allowedMethodsString := join(methodStrings[:], ", ")
                headers["Access-Control-Allow-Methods"] = allowedMethodsString
            }

            if len(corsOptions.allowHeaders) > 0 {
                allowedHeadersString := join(corsOptions.allowHeaders, ", ")
                headers["Access-Control-Allow-Headers"] = allowedHeadersString
            }

            maxAgeString := tprintf("%d", corsOptions.maxAge)
            headers["Access-Control-Max-Age"] = maxAgeString
        }

        if len(corsOptions.exposeHeaders) > 0 {
            exposeHeadersString := join(corsOptions.exposeHeaders, ", ")
            headers["Access-Control-Expose-Headers"] = exposeHeadersString
        }
    }
}

// Default CORS options that allow specific origins and common methods
make_default_cors_options :: proc(server: ^lib.Server) -> ^lib.CorsOptions {
    using lib
    using fmt

    defaultCorsOptions := new(lib.CorsOptions)
    if defaultCorsOptions == nil {
        free(defaultCorsOptions)
        return nil
    }

    defaultCorsOptions.allowOrigins = server.config.cors.allowedOrigins
    defaultCorsOptions.allowMethods = server.config.cors.allowedMethods
    defaultCorsOptions.allowHeaders = server.config.cors.allowedHeaders
    defaultCorsOptions.exposeHeaders = []string{}
    defaultCorsOptions.allowCredentials = server.config.cors.allowCredentials
    defaultCorsOptions.maxAge = server.config.cors.maxAgeSeconds

    return defaultCorsOptions
}

// Handle OPTIONS preflight requests
handle_options_request :: proc(server: ^lib.Server, method: lib.HttpMethod, path: string, headers: map[string]string, args: []string = {""}) -> (^lib.HttpStatus, string) {
    using lib
    using fmt

    // Create response headers with CORS headers
    responseHeaders := make(map[string]string)
    defer delete(responseHeaders)

    // Apply CORS options for preflight
    apply_cors_headers(server, &responseHeaders, headers, method)

    // Return 204 No Content for OPTIONS requests I guess this standard for CORS preflight
    return make_new_http_status(.NO_CONTENT, HttpStatusText[.NO_CONTENT]), ""
}