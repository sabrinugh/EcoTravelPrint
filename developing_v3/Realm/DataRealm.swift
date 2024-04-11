//
//  DataRealm.swift
//  developing_v3
//
//  Created by Sabrina Boc on 29/03/2024.
//

import UIKit
import RealmSwift

// Define Realm model objects
class Emission: Object {
    @Persisted var value: Double = 0.0
    @Persisted var date: Date = Date()
    // Link the emissions with the corresponding trip
    @Persisted(originProperty: "emissions") var trip: LinkingObjects<Trip>
}

class Location: Object {
    @Persisted var name: String = ""
    @Persisted var latitude: Double = 0.0
    @Persisted var longitude: Double = 0.0
}

class RouteInfo: Object {
    @Persisted var origin: Location?
    @Persisted var destination: Location?
    @Persisted var methodOfTravel: String?
    @Persisted var polylinePoints: String?
}

class Trip: Object {
    // Give an ID to the trip - unique ID to act as primary key
    @Persisted var id: String = UUID().uuidString
    
    // Emissions attached to a given trip
    @Persisted var emissions: List<Emission>
    @Persisted var destination: Location?
    @Persisted var origin: Location?
    @Persisted var methodOfTravel: String?
    
    @Persisted var routeInfo: RouteInfo?
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

