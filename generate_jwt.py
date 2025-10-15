import json
import base64
######################################
# Author: Marshall A. Burns
# GitHub: @SchoolyB
#
# Copyright (c) 2025-Present Marshall A Burns
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
######################################

# To use:
#1.`python3 generate_jwt`
#2. Take that generated token and set it as the PUBLIC_OSTRICHDB_TOKEN value
#     in your .env file
# Note: Be sure there is NO whitespace when you store the value


payload = {
    "sub": "user_2abcdef123456789",
    "iss": "http://oVault.com",
    "azp": "http://localhost:8042",
    "exp": 9999999999,
    "iat": 1640908800,
    "nbf": 1640908800,
    "jti": "jwt_123456789abcdef",
}

header = {
    "alg": "RS256",
    "typ": "JWT"
}

def base64url_encode(data):
    return base64.urlsafe_b64encode(json.dumps(data).encode()).decode().rstrip('=')

header_b64 = base64url_encode(header)
payload_b64 = base64url_encode(payload)

fake_jwt = f"{header_b64}.{payload_b64}.fake_signature"

print("Generated JWT Token:")
print(fake_jwt)
print()
print("Store this token as the value for PUBLIC_OSTRICHDB_TOKEN in your .env file")
print("Or just copy this:")
print(f'PUBLIC_OSTRICHDB_TOKEN={fake_jwt}')