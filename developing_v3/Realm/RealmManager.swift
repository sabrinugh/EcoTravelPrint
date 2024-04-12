//
//  RealmManager.swift
//  developing_v3
//
//  Created by Sabrina Boc on 29/03/2024.
//
import RealmSwift

class RealmManager {
    static let shared = RealmManager()
    
    // Increment the schema version to trigger migration
    private let schemaVersion: UInt64 = 3
    
    private init() {
        // Update to allow duration to be a new data field in RouteInfo object
        let config = Realm.Configuration(
            schemaVersion: schemaVersion,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    // Perform migration for version 1
                    // Add the 'duration' property to the 'RouteInfo' object
                    migration.enumerateObjects(ofType: RouteInfo.className()) { oldObject, newObject in
                        // Set the default value for 'duration' if needed
                        newObject?["distance"] = 0.0
                    }
                }
            })
        
        // Use the new configuration
        Realm.Configuration.defaultConfiguration = config
    }
    
    func getRealm() -> Realm {
        do {
            // Return the Realm instance with the updated configuration
            return try Realm()
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }
}
