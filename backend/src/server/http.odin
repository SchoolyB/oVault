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


@(require_results)
make_new_http_status :: proc(statusCode: lib.HttpStatusCode, text:string) -> ^lib.HttpStatus {
    using lib

    httpStatus:= new(HttpStatus)
    httpStatus.statusCode = statusCode
    httpStatus.text = text

    return httpStatus
}


@(require_results)
parse_http_request :: proc(data:[]byte) -> (method: lib.HttpMethod, path: string, headers: map[string]string){
    using lib
    using strings

    lines:= split(string(data), "\r\n")
    defer delete(lines)

    if len(lines) < 1 {
        return nil, "HTTP request empty", nil
    }

    requestParts:= fields(lines[0])
    defer delete(requestParts)

   	if len(requestParts) != 3 {
		return nil, "", nil
	}

	methodStringPart := trim_space(requestParts[0])

	for httpMethod , index in HttpMethodString{
	    if methodStringPart == httpMethod{
		   method = index
			break
	   }
	}

	path = trim_space(requestParts[1])

	headers = make(map[string]string)
	headerEnd := 1

	//Iterate through the lines of the request
	for i := 1; i < len(lines); i += 1 {
		if lines[i] == "" { 	//if the line is empty, the headers are done and set the headerEnd to the current index
			headerEnd = i
			break
		}

		//split the line into key and value
		headerParts := strings.split(lines[i], ": ")
		defer delete(headerParts)

		//Add it to the headers map
		if len(headerParts) == 2 {
			headers[headerParts[0]] = headerParts[1]
		}

	}

	return method, path, headers
}

//Feel free to pass in a specific version when you call this
@(require_results)
build_http_response :: proc(status: ^lib.HttpStatus, headers: map[string]string, body: string, version:= "v1") -> []byte {
    using lib
    using fmt
    using strings

	version := tprintf("Server Version: %s\r\n", version)
	response := tprintf("HTTP/1.1 %d %s\r\n", int(status.statusCode), status.text)

	//Default headers
	response = concatenate([]string{response, version})
	response = concatenate([]string{response, tprintf("Content-Length: %d\r\n", len(body))})
	response = concatenate([]string{response, "Connection: close\r\n"})

	for key, value in headers {
		response = concatenate([]string{response, tprintf("%s: %s\r\n", key, value)})
	}

	response = concatenate([]string{response, "\r\n"})

	if len(body) > 0 {
		response = concatenate([]string{response, body})
	}

	return transmute([]byte)response
}
