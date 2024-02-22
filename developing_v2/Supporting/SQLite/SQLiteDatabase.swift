//
//  SQLiteDatabase.swift
//  developing_v2
//
//  Created by Sabrina Boc on 22/02/2024.
//

import Foundation
import SQLite

class SQLiteDatabase {
    
    static let sharedInstance = SQLiteDatabase()
    var database : Connection?
    
    private init() {
            // Create connection to database
            do {
                let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                
                let fileUrl = documentDirectory.appendingPathComponent("contactList").appendingPathExtension("sqlite3")
                
                database = try Connection(fileUrl.path)
            } catch {
                print("Creating connection to database error: \(error)")
            }
        }
        
        // Creating Table
        func createTable() {
            SQLiteCommands.createTable()
        }
}
