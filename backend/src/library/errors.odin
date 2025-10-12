package library

import "base:runtime"
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

ErrorType :: enum {
   NONE = 0,
   UNKOWN,
   WARNING,
   ERROR,
   CRITICAL
}

SourceCodeLocation::runtime.Source_Code_Location
#assert(SourceCodeLocation == runtime.Source_Code_Location)

Error :: struct {
    type: ErrorType,
	message:   string,
	location:  SourceCodeLocation
}

get_caller_location :: proc(location:= #caller_location) -> SourceCodeLocation {
    return location
}


make_error ::proc(msg:string= "No Error", type:ErrorType=.NONE, loc:= #caller_location) -> Error{
    return Error{ message = msg, type = type, location = loc}
}


