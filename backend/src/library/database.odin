package library

import "core:fmt"
import "core:c"
import "core:strings"
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

Database :: struct {
    conn: ^Connection,
    filename: cstring,
    fullPath: string,
}

init_database :: proc()-> Database {
    b:=new(strings.Builder)
    b.buf = make([dynamic]byte)
    strings.builder_init(b)
    defer strings.builder_destroy(b)
    strings.write_string(b, "./oVault.sqlite")



    db: Database
    db.conn = new(Connection)
    db.filename = strings.to_cstring(b)


    // Open the database file.
    if open(db.filename, &db.conn) != .Ok {
        panic("Failed to open SQLite database connection")
    }

    defer close(db.conn)

	fmt.println("Successfully Connected to SQLite database!")

	defer {
		close(db.conn)
		fmt.println("\nConnection closed")
	}

	create_initial_tables(db)

	return db
}

close_db :: proc(db:^Database){
    if db.conn != nil {
        close(db.conn)
        db.conn = nil
     }
}

create_initial_tables :: proc(db:Database) -> bool{
    usersTable := SQL_CREATE_USERS_TABLE
    passwordEntriesTable := SQL_CREATE_PASSWORD_ENTRIES_TABLE
    sessionsTable := SQL_CREATE_SESSIONS_TABLE

    tables := []string{usersTable, passwordEntriesTable, sessionsTable}

    indexes := []string{
        "CREATE INDEX IF NOT EXISTS idx_password_entries_user_id ON password_entries(user_id);",
        "CREATE INDEX IF NOT EXISTS idx_sessions_token ON sessions(token);",
        "CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON sessions(user_id);",
    }


        for t in tables {
            result := exec(db.conn, cstring(raw_data(t)), nil, nil, nil)
            if result != .Ok {
                fmt.printfln("Failed to create table:", result)
                return false
            }
        }

        // Create indexes
        for indexSQL in indexes {
            result := exec(db.conn, cstring(raw_data(indexSQL)), nil, nil, nil)
            if result != .Ok {
                fmt.printfln("Failed to create index:", result)
                return false
            }
        }

        fmt.println("Database tables created successfully")
        return true
}



// // Execute a simple SQL statement (for INSERT, UPDATE, DELETE)
// exec_sql :: proc(db: ^Database, sql: string) -> Result_Code {
//     return sqlite3_exec(db.conn, cstring(raw_data(sql)), nil, nil, nil)
// }

// // Prepare a SQL statement
// prepare_statement :: proc(db: ^Database, sql: string) -> (stmt: ^Statement, ok: bool) {
//     result := sqlite3_prepare_v2(db.conn, cstring(raw_data(sql)), c.int(len(sql)), &stmt, nil)
//     if result != .Ok {
//         fmt.eprintln("Failed to prepare statement:", result)
//         return nil, false
//     }
//     return stmt, true
// }

// // Finalize (clean up) a prepared statement
// finalize_statement :: proc(stmt: ^Statement) {
//     sqlite3_finalize(stmt)
// }

// // Step through query results
// step_statement :: proc(stmt: ^Statement) -> Result_Code {
//     return sqlite3_step(stmt)
// }

// // Bind parameters to prepared statements
// bind_text :: proc(stmt: ^Statement, index: c.int, value: string) -> Result_Code {
//     return sqlite3_bind_text(stmt, index, cstring(raw_data(value)), c.int(len(value)), nil)
// }

// bind_int64 :: proc(stmt: ^Statement, index: c.int, value: i64) -> Result_Code {
//     return sqlite3_bind_int64(stmt, index, c.int64_t(value))
// }

// // Get column values from result
// column_int64 :: proc(stmt: ^Statement, index: c.int) -> i64 {
//     return i64(sqlite3_column_int64(stmt, index))
// }

// column_text :: proc(stmt: ^Statement, index: c.int) -> string {
//     text := sqlite3_column_text(stmt, index)
//     if text == nil {
//         return ""
//     }
//     return strings.clone(string(text))
// }

// // Get last inserted row ID
// last_insert_rowid :: proc(db: ^Database) -> i64 {
//     stmt, ok := prepare_statement(db, "SELECT last_insert_rowid();")
//     if !ok {
//         return 0
//     }
//     defer finalize_statement(stmt)

//     if step_statement(stmt) == .Row {
//         return column_int64(stmt, 0)
//     }
//     return 0
// }

// // =============================================================================
// // USER DATABASE OPERATIONS
// // =============================================================================

// // Create a new user
// create_user :: proc(db: ^Database, username: string, password_hash: string, salt: string) -> (user_id: i64, ok: bool) {
//     sql := "INSERT INTO users (username, password_hash, salt, created_at, updated_at) VALUES (?, ?, ?, ?, ?);"

//     stmt, prep_ok := prepare_statement(db, sql)
//     if !prep_ok {
//         return 0, false
//     }
//     defer finalize_statement(stmt)

//     now := time.now()
//     timestamp := time.to_unix(now)

//     // Bind parameters
//     bind_text(stmt, 1, username)
//     bind_text(stmt, 2, password_hash)
//     bind_text(stmt, 3, salt)
//     bind_int64(stmt, 4, timestamp)
//     bind_int64(stmt, 5, timestamp)

//     // Execute
//     result := step_statement(stmt)
//     if result != .Done {
//         fmt.eprintln("Failed to create user:", result)
//         return 0, false
//     }

//     user_id = last_insert_rowid(db)
//     return user_id, true
// }

// // Get user by username
// get_user_by_username :: proc(db: ^Database, username: string) -> (user: User, ok: bool) {
//     sql := "SELECT id, username, password_hash, salt, created_at, updated_at FROM users WHERE username = ?;"

//     stmt, prep_ok := prepare_statement(db, sql)
//     if !prep_ok {
//         return user, false
//     }
//     defer finalize_statement(stmt)

//     bind_text(stmt, 1, username)

//     result := step_statement(stmt)
//     if result != .Row {
//         return user, false
//     }

//     // Read columns
//     user.id = column_int64(stmt, 0)
//     user.username = column_text(stmt, 1)
//     user.password_hash = column_text(stmt, 2)
//     user.salt = column_text(stmt, 3)
//     user.created_at = column_int64(stmt, 4)
//     user.updated_at = column_int64(stmt, 5)

//     return user, true
// }

// // Get user by ID
// get_user_by_id :: proc(db: ^Database, user_id: i64) -> (user: User, ok: bool) {
//     sql := "SELECT id, username, password_hash, salt, created_at, updated_at FROM users WHERE id = ?;"

//     stmt, prep_ok := prepare_statement(db, sql)
//     if !prep_ok {
//         return user, false
//     }
//     defer finalize_statement(stmt)

//     bind_int64(stmt, 1, user_id)

//     result := step_statement(stmt)
//     if result != .Row {
//         return user, false
//     }

//     // Read columns
//     user.id = column_int64(stmt, 0)
//     user.username = column_text(stmt, 1)
//     user.password_hash = column_text(stmt, 2)
//     user.salt = column_text(stmt, 3)
//     user.created_at = column_int64(stmt, 4)
//     user.updated_at = column_int64(stmt, 5)

//     return user, true
// }

// // Check if user exists by username
// user_exists :: proc(db: ^Database, username: string) -> bool {
//     sql := "SELECT COUNT(*) FROM users WHERE username = ?;"

//     stmt, prep_ok := prepare_statement(db, sql)
//     if !prep_ok {
//         return false
//     }
//     defer finalize_statement(stmt)

//     bind_text(stmt, 1, username)

//     result := step_statement(stmt)
//     if result != .Row {
//         return false
//     }

//     count := column_int64(stmt, 0)
//     return count > 0
// }

// // =============================================================================
// // PASSWORD ENTRY DATABASE OPERATIONS
// // =============================================================================

// // Create a new password entry
// create_password_entry :: proc(db: ^Database, entry: Password_Entry) -> (password_id: i64, ok: bool) {
//     sql := "INSERT INTO password_entries (user_id, title, username, encrypted_password, url, notes, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?);"

//     stmt, prep_ok := prepare_statement(db, sql)
//     if !prep_ok {
//         return 0, false
//     }
//     defer finalize_statement(stmt)

//     now := time.now()
//     timestamp := time.to_unix(now)

//     bind_int64(stmt, 1, entry.user_id)
//     bind_text(stmt, 2, entry.title)
//     bind_text(stmt, 3, entry.username)
//     bind_text(stmt, 4, entry.encrypted_password)
//     bind_text(stmt, 5, entry.url)
//     bind_text(stmt, 6, entry.notes)
//     bind_int64(stmt, 7, timestamp)
//     bind_int64(stmt, 8, timestamp)

//     result := step_statement(stmt)
//     if result != .Done {
//         fmt.eprintln("Failed to create password entry:", result)
//         return 0, false
//     }

//     password_id = last_insert_rowid(db)
//     return password_id, true
// }

// // Get all password entries for a user
// get_password_entries_by_user :: proc(db: ^Database, user_id: i64) -> (entries: [dynamic]Password_Entry, ok: bool) {
//     sql := "SELECT id, user_id, title, username, encrypted_password, url, notes, created_at, updated_at FROM password_entries WHERE user_id = ? ORDER BY title ASC;"

//     stmt, prep_ok := prepare_statement(db, sql)
//     if !prep_ok {
//         return entries, false
//     }
//     defer finalize_statement(stmt)

//     bind_int64(stmt, 1, user_id)

//     entries = make([dynamic]Password_Entry)

//     for {
//         result := step_statement(stmt)
//         if result == .Done {
//             break
//         }
//         if result != .Row {
//             fmt.eprintln("Error reading password entries:", result)
//             return entries, false
//         }

//         entry: Password_Entry
//         entry.id = column_int64(stmt, 0)
//         entry.user_id = column_int64(stmt, 1)
//         entry.title = column_text(stmt, 2)
//         entry.username = column_text(stmt, 3)
//         entry.encrypted_password = column_text(stmt, 4)
//         entry.url = column_text(stmt, 5)
//         entry.notes = column_text(stmt, 6)
//         entry.created_at = column_int64(stmt, 7)
//         entry.updated_at = column_int64(stmt, 8)

//         append(&entries, entry)
//     }

//     return entries, true
// }

// // Get a single password entry by ID
// get_password_entry_by_id :: proc(db: ^Database, entry_id: i64, user_id: i64) -> (entry: Password_Entry, ok: bool) {
//     sql := "SELECT id, user_id, title, username, encrypted_password, url, notes, created_at, updated_at FROM password_entries WHERE id = ? AND user_id = ?;"

//     stmt, prep_ok := prepare_statement(db, sql)
//     if !prep_ok {
//         return entry, false
//     }
//     defer finalize_statement(stmt)

//     bind_int64(stmt, 1, entry_id)
//     bind_int64(stmt, 2, user_id)

//     result := step_statement(stmt)
//     if result != .Row {
//         return entry, false
//     }

//     entry.id = column_int64(stmt, 0)
//     entry.user_id = column_int64(stmt, 1)
//     entry.title = column_text(stmt, 2)
//     entry.username = column_text(stmt, 3)
//     entry.encrypted_password = column_text(stmt, 4)
//     entry.url = column_text(stmt, 5)
//     entry.notes = column_text(stmt, 6)
//     entry.created_at = column_int64(stmt, 7)
//     entry.updated_at = column_int64(stmt, 8)

//     return entry, true
// }

// // Update a password entry
// update_password_entry :: proc(db: ^Database, entry: Password_Entry) -> bool {
//     sql := "UPDATE password_entries SET title = ?, username = ?, encrypted_password = ?, url = ?, notes = ?, updated_at = ? WHERE id = ? AND user_id = ?;"

//     stmt, prep_ok := prepare_statement(db, sql)
//     if !prep_ok {
//         return false
//     }
//     defer finalize_statement(stmt)

//     now := time.now()
//     timestamp := time.to_unix(now)

//     bind_text(stmt, 1, entry.title)
//     bind_text(stmt, 2, entry.username)
//     bind_text(stmt, 3, entry.encrypted_password)
//     bind_text(stmt, 4, entry.url)
//     bind_text(stmt, 5, entry.notes)
//     bind_int64(stmt, 6, timestamp)
//     bind_int64(stmt, 7, entry.id)
//     bind_int64(stmt, 8, entry.user_id)

//     result := step_statement(stmt)
//     return result == .Done
// }

// // Delete a password entry
// delete_password_entry :: proc(db: ^Database, entry_id: i64, user_id: i64) -> bool {
//     sql := "DELETE FROM password_entries WHERE id = ? AND user_id = ?;"

//     stmt, prep_ok := prepare_statement(db, sql)
//     if !prep_ok {
//         return false
//     }
//     defer finalize_statement(stmt)

//     bind_int64(stmt, 1, entry_id)
//     bind_int64(stmt, 2, user_id)

//     result := step_statement(stmt)
//     return result == .Done
// }

// // =============================================================================
// // SESSION DATABASE OPERATIONS
// // =============================================================================

// // Create a new session
// create_session :: proc(db: ^Database, user_id: i64, token: string, expires_at: i64) -> (session_id: i64, ok: bool) {
//     sql := "INSERT INTO sessions (user_id, token, expires_at, created_at) VALUES (?, ?, ?, ?);"

//     stmt, prep_ok := prepare_statement(db, sql)
//     if !prep_ok {
//         return 0, false
//     }
//     defer finalize_statement(stmt)

//     now := time.now()
//     timestamp := time.to_unix(now)

//     bind_int64(stmt, 1, user_id)
//     bind_text(stmt, 2, token)
//     bind_int64(stmt, 3, expires_at)
//     bind_int64(stmt, 4, timestamp)

//     result := step_statement(stmt)
//     if result != .Done {
//         fmt.eprintln("Failed to create session:", result)
//         return 0, false
//     }

//     session_id = last_insert_rowid(db)
//     return session_id, true
// }

// // Get session by token
// get_session_by_token :: proc(db: ^Database, token: string) -> (session: Session, ok: bool) {
//     sql := "SELECT id, user_id, token, expires_at, created_at FROM sessions WHERE token = ?;"

//     stmt, prep_ok := prepare_statement(db, sql)
//     if !prep_ok {
//         return session, false
//     }
//     defer finalize_statement(stmt)

//     bind_text(stmt, 1, token)

//     result := step_statement(stmt)
//     if result != .Row {
//         return session, false
//     }

//     session.id = column_int64(stmt, 0)
//     session.user_id = column_int64(stmt, 1)
//     session.token = column_text(stmt, 2)
//     session.expires_at = column_int64(stmt, 3)
//     session.created_at = column_int64(stmt, 4)

//     return session, true
// }

// // Delete session by token (logout)
// delete_session :: proc(db: ^Database, token: string) -> bool {
//     sql := "DELETE FROM sessions WHERE token = ?;"

//     stmt, prep_ok := prepare_statement(db, sql)
//     if !prep_ok {
//         return false
//     }
//     defer finalize_statement(stmt)

//     bind_text(stmt, 1, token)

//     result := step_statement(stmt)
//     return result == .Done
// }

// // Delete all sessions for a user
// delete_user_sessions :: proc(db: ^Database, user_id: i64) -> bool {
//     sql := "DELETE FROM sessions WHERE user_id = ?;"

//     stmt, prep_ok := prepare_statement(db, sql)
//     if !prep_ok {
//         return false
//     }
//     defer finalize_statement(stmt)

//     bind_int64(stmt, 1, user_id)

//     result := step_statement(stmt)
//     return result == .Done
// }

// // Clean up expired sessions
// cleanup_expired_sessions :: proc(db: ^Database) -> bool {
//     now := time.now()
//     timestamp := time.to_unix(now)

//     sql := "DELETE FROM sessions WHERE expires_at < ?;"

//     stmt, prep_ok := prepare_statement(db, sql)
//     if !prep_ok {
//         return false
//     }
//     defer finalize_statement(stmt)

//     bind_int64(stmt, 1, timestamp)

//     result := step_statement(stmt)
//     return result == .Done
// }
