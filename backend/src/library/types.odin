package library

import "core:time"
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

Server :: struct {
    version: string,
    apiBase: string,
    startTimestamp: time.Time,
    config : Config,

    //Add more shit here if you need. Timestamps, etc....
}

Config :: struct {
    port, backlogSize, maxConnections, requestTimeoutSeconds: int,
    host, bindAddress, apiVersion: string,

    security : struct {
        maxRequestBodySizeMb : int,
    },

    cors : struct {
        allowedOrigins,  allowedHeaders, exposeHeaders:[]string,
        allowedMethods: []HttpMethod,
        maxAgeSeconds: int,
        allowCredentials: bool
    },

}

HttpStatusCode :: enum{
    OK                  = 200,
    CREATE              = 201,
    NO_CONTENT          = 204,
    PARTIAL_CONTENT     = 206,
    MOVED_PERMANENTLY   = 301,
    FOUND               = 302,
    NOT_MODIFIED        = 304,
    BAD_REQUEST         = 400,
    UNAUTHORIZED        = 401,
    FORBIDDEN           = 403,
    NOT_FOUND           = 404,
    METHOD_NOT_ALLOWED  = 405,
    CONFLICT            = 409,
    PAYLOAD_TOO_LARGE   = 413,
    UNSUPPORTED_MEDIA   = 415,
    TOO_MANY_REQUESTS   = 429,
    SERVER_ERROR        = 500,
    NOT_IMPLEMENTED     = 501,
    BAD_GATEWAY         = 502,
    SERVICE_UNAVAILABLE = 503,
    GATEWAY_TIMEOUT     = 504,
}

HttpStatus :: struct {
    statusCode: HttpStatusCode,
    text: string
}


HttpMethod :: enum {
    HEAD = 0,
    GET,
    POST,
    PUT,
    DELETE,
    OPTIONS,
}

HttpMethodString := [HttpMethod]string{
    .HEAD = "HEAD",
    .GET    = "GET",
    .POST    = "POST",
    .PUT    = "PUT",
    .DELETE    = "DELETE",
    .OPTIONS = "OPTIONS",
}


RouteHandler ::proc(server: ^Server, method: HttpMethod,path:string, headers:map[string]string, args:[]string) -> (^HttpStatus, string)

Route :: struct {
    method: HttpMethod,
    path: string,
    handler: RouteHandler
}

Router :: struct {
    routes: [dynamic]Route
}

//Cant find docs on #sparse. Just used the compilers error message if you removed it
HttpStatusText :: #sparse[HttpStatusCode]string {
    //2xx codes
    .OK                  = "OK",
    .CREATE              = "Created",
    .NO_CONTENT          = "No Content",
    .PARTIAL_CONTENT     = "Partial Content",
    //3xx codes
    .MOVED_PERMANENTLY   = "Moved Permanently",
    .FOUND               = "Found",
    .NOT_MODIFIED        = "Not Modified",
    //4xx codes
    .BAD_REQUEST         = "Bad Request",
    .UNAUTHORIZED        = "Unauthorized",
    .FORBIDDEN           = "Forbidden",
    .NOT_FOUND           = "Not Found",
    .METHOD_NOT_ALLOWED  = "Method Not Allowed",
    .CONFLICT            = "Conflict",
    .PAYLOAD_TOO_LARGE   = "Payload Too Large",
    .UNSUPPORTED_MEDIA   = "Unsupported Media Type",
    .TOO_MANY_REQUESTS   = "Too Many Requests",
    //5xx codes
    .SERVER_ERROR        = "Internal Server Error",
    .NOT_IMPLEMENTED     = "Not Implemented",
    .BAD_GATEWAY         = "Bad Gateway",
    .SERVICE_UNAVAILABLE = "Service Unavailable",
    .GATEWAY_TIMEOUT     = "Gateway Timeout",
}


CorsOptions :: struct {
    allowOrigins: []string,           // List of allowed origins, use ["*"] for all
    allowMethods: []HttpMethod,   // List of allowed HTTP methods
    allowHeaders: []string,           // List of allowed headers
    exposeHeaders: []string,          // List of headers exposed to the browser
    allowCredentials: bool,           // Whether to allow credentials (cookies, etc.)
    maxAge: int,                      // How long preflight requests can be cached (in seconds)
}