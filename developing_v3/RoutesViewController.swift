//
//  RoutesViewController.swift
//  developing_v3
//
//  Created by Sabrina Boc on 10/04/2024.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces
import SwiftyJSON

class RoutesViewController: UIViewController, CLLocationManagerDelegate {
    var originCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    var transportMode: String = ""
    var carbonEmissions: Float = 0.00
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("In the RoutesViewController") // debug line
        
        print(originCoordinate.longitude, originCoordinate.latitude)
        print(destinationCoordinate.longitude, destinationCoordinate.latitude)
        searchRoute(origin: originCoordinate, destination: destinationCoordinate)
    }
    
    
    // MARK: Find the route using a HTTP request to the Google Maps Directions API and using in-built URLSession API to process the request. Gives driving directions as no other method is currently specified
    func searchRoute(origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        let apiKey = "AIzaSyApAdbhB2IiywBbxbyv5baoT9vrvHr9rcU"
        let originString = "\(origin.latitude),\(origin.longitude)"
        let destinationString = "\(destination.latitude),\(destination.longitude)"
        let modeString = transportMode.lowercased()
    
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(originString)&destination=\(destinationString)&mode=\(modeString)&key=\(apiKey)")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Ensure program does not crash if error occurs
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
                
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                // Parse the JSON response and extract route information
                // Handle the route information (e.g., draw route on map)
                print("JSON Response: \(json ?? [:])")
                print("Mode of transport: ", modeString)
                print("OriginString: ", originString)
                print("DestinationString: ", destinationString)
                
                // Calculate GHG emissions based on the distance and method of travel
                if let jsonObject = json {
                    if modeString == "walking" || modeString == "cycling" {
                        let totalDistance = self.calculateTotalDistance(from: jsonObject)
                        self.carbonEmissions = 0
                    }
                    if modeString == "transit"{
                        let totalDistance = self.calculateTransitDistance(from: jsonObject)
                        
                    }
                    else { // Given that default is driving, calculate the avg. GHG emissions
                        let totalDistance = self.calculateTotalDistance(from: jsonObject)
                        print("Total distance: \(totalDistance ?? 0) meters")
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    // MARK: Using SwiftyJSON to manage and parse the returned JSON directions to find distance and thereby calculate the CO2 emissions
    func calculateTotalDistance(from json: [String: Any]) -> Float? {
        // Check if the JSON contains the "routes" array
        guard let routes = json["routes"] as? [[String: Any]] else {
            print("Routes not found in JSON")
            return nil
        }
        var totalDistance = 0
        for route in routes {
            if let legs = route["legs"] as? [[String: Any]] {
                for leg in legs {
                    if let distance = leg["distance"] as? [String: Any], let value = distance["value"] as? Float {
                        totalDistance += Int(value)
                    }
                }
            }
        }
        
        return Float(totalDistance)
    }
    
    // Same as above but searches for transit distance to calculate emissions
    func calculateTransitDistance(from json: [String: Any]) -> Int? {
        guard let routes = json["routes"] as? [[String: Any]] else {
            print("Routes not found in JSON")
            return nil
        }
        
        var totalTransitDistance = 0
        
        for route in routes {
            guard let legs = route["legs"] as? [[String: Any]] else {
                continue
            }
            
            for leg in legs {
                guard let steps = leg["steps"] as? [[String: Any]] else {
                    continue
                }
                
                for step in steps {
                    guard let travelMode = step["travel_mode"] as? String else {
                        continue
                    }
                    
                    if travelMode == "TRANSIT" {
                        if let distance = step["distance"] as? [String: Any], let value = distance["value"] as? Int {
                            totalTransitDistance += value
                        }
                    }
                }
            }
        }
        
        return totalTransitDistance
    }
}
