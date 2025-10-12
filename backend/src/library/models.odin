package library

// /*
// Copyright (c) 2025-Present Marshall A. Burns

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//     http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// */

// // Database models for oVault password manager

// User :: struct {
//     id: i64,
//     username: string,
//     password_hash: string,
//     salt: string,
//     created_at: i64,
//     updated_at: i64,
// }

// Password_Entry :: struct {
//     id: i64,
//     user_id: i64,
//     title: string,
//     username: string,
//     encrypted_password: string,  // Base64 encoded encrypted password
//     url: string,
//     notes: string,
//     created_at: i64,
//     updated_at: i64,
// }

// Session :: struct {
//     id: i64,
//     user_id: i64,
//     token: string,
//     expires_at: i64,
//     created_at: i64,
// }

// // Request/Response DTOs for API

// Login_Request :: struct {
//     username: string,
//     password: string,
// }

// Login_Response :: struct {
//     token: string,
//     user_id: i64,
//     username: string,
// }

// Register_Request :: struct {
//     username: string,
//     password: string,
// }

// Register_Response :: struct {
//     user_id: i64,
//     username: string,
// }

// Create_Password_Request :: struct {
//     title: string,
//     username: string,
//     password: string,
//     url: string,
//     notes: string,
// }

// Update_Password_Request :: struct {
//     title: string,
//     username: string,
//     password: string,
//     url: string,
//     notes: string,
// }

// Password_Response :: struct {
//     id: i64,
//     title: string,
//     username: string,
//     password: string,  // Will be decrypted before sending
//     url: string,
//     notes: string,
//     created_at: i64,
//     updated_at: i64,
// }

// Error_Response :: struct {
//     error: string,
//     message: string,
// }
