//
//  SQLiteCommands.swift
//  developing_v2
//
//  Created by Sabrina Boc on 22/02/2024.
//

import Foundation
import SQLite
import SQLite3

class SQLiteCommands {
    static var table = Table("user")
    
    static let email = Expression<String>("email")
    static let firstName = Expression<String>("firstName")
    static let lastName = Expression<String>("lastName")
    static let password = Expression<String>("password")
    static let photo = Expression<Data>("photo")
    
    // MARK: Create a new table into SQLite - if it already exists, don't create it. Print if connection fails or table already exists.
    static func createTable() {
        guard let database = SQLiteDatabase.sharedInstance.database else {
            print("Connection to DB error")
            return
        }
        
        do {
            try database.run(table.create(ifNotExists : true) { table in
                table.column(email, primaryKey: true)
                table.column(firstName)
                table.column(lastName)
                table.column(password)
                table.column(photo)
                
            })
        } catch {
            print("Table already exists: \(error)")
        }
    }
    
    // MARK: Inserting new information into the table that has been connected
    static func insertRow (_ userValues: UserModel) -> Bool? {
        // Check if the connection to DB is ready
        guard let database = SQLiteDatabase.sharedInstance.database else {
            print("Connection to DB error")
            return nil
        }
        
        do {
            try database.run(table.insert(email <- userValues.email, firstName <- userValues.firstName, lastName <- userValues.lastName, password <- userValues.password, photo <- userValues.photo))
            return true
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("Insert row failed: \(message), in \(String(describing: statement))")
            return false
        } catch let error {
            print("Insertion failed: \(error)")
            return false
        }
    }
}
