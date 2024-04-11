//
//  RealmManager.swift
//  developing_v3
//
//  Created by Sabrina Boc on 29/03/2024.
//
import RealmSwift

class RealmManager {
    static let shared = RealmManager()

    private init() {}

    func getRealm() -> Realm {
        var config = Realm.Configuration()

        // Set the schema version and migration block
        config.schemaVersion = 1 // Increment the schema version when you modify the schema
        config.migrationBlock = { migration, oldSchemaVersion in
            if oldSchemaVersion < 1 {
                // Perform migration if needed
                migration.enumerateObjects(ofType: Trip.className()) { oldObject, newObject in
                    // Add or modify properties as needed
                    newObject?["routeInfo"] = nil // Set default value or perform necessary changes
                }
            }
        }

        // Apply the configuration
        Realm.Configuration.defaultConfiguration = config

        // Return the Realm instance
        do {
            let realm = try Realm()
            return realm
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }
}
