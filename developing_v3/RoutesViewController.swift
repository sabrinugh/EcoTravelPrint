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
import RealmSwift

class RoutesViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var selectRoute: UIButton!
    @IBOutlet weak var mapView: UIView!
    
    weak var tripAddedDelegate: TripAddedDelegate? // Update the table view of all saved routes
    
    var locationManager: CLLocationManager!
    var preciseLocationZoomLevel = 10
    var approximateLocationZoomLevel = 20
    var GMSmapView: GMSMapView!
    
    var originCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    var transportMode: String = ""
    var totalCarbonEmission: Double = 0.00
    var carbonEmissionLDV = 2.45
    var points: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("In the RoutesViewController") // debug line
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        openMap()
        
        searchRoute(origin: originCoordinate, destination: destinationCoordinate)
    }
    
    
    // MARK: Open the GMSMap into the stackView
    public func openMap() {
        if locationManager.accuracyAuthorization == .fullAccuracy {
            print("Precise location")
        } else {
            print("Inaccurate location")
        }
        let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
        let options = GMSMapViewOptions()
        // Set default coordinates to Co. Dublin, Ireland
        options.camera = GMSCameraPosition.camera(withLatitude: 53.3498, longitude: -6.2603, zoom: Float(zoomLevel))
        
        if let mapView = mapView {
            options.frame = mapView.bounds
            
            // Update the class-level variable instead of creating a new local variable
            GMSmapView = GMSMapView(options: options)
            GMSmapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            GMSmapView.isMyLocationEnabled = true
            GMSmapView.settings.myLocationButton = true // Button to display current location
            
            mapView.addSubview(GMSmapView)
        } else {
            // Handle the case where mapView is nil
            print("Error: mapView is nil")
        }
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
                // API calls can only be made on main thread, DispatchQueue to execute
                DispatchQueue.main.async { [self] in
                    print("JSON Response: \(json ?? [:])")
                    print("Mode of transport: ", modeString)
                    print("OriginString: ", originString)
                    print("DestinationString: ", destinationString)
                    
                    self.totalCarbonEmission = calculateRouteDistanceAndEmissions(from: json ?? [:], forTransport: modeString)!
                    
                    self.displayRouteOnMap(json: json ?? [:]) // Call to display the route
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    // MARK: Using the searched routes given polyline, display it on the map to user
    func displayRouteOnMap(json: [String: Any]) {
        guard let routes = json["routes"] as? [[String: Any]] else {
            print("Routes not found in JSON")
            return
        }
        
        var bounds = GMSCoordinateBounds()
        // Extract polyline points from the first route
        if let route = routes.first,
           let routeOverviewPolyline = route["overview_polyline"] as? [String: Any],
           let points = routeOverviewPolyline["points"] as? String {
            self.points = points // To save into DB
        } else {
            print("Polyline points not found in JSON")
        }
        
        for route in routes {
            guard let routeOverviewPolyline = route["overview_polyline"] as? [String: Any],
                  let points = routeOverviewPolyline["points"] as? String,
                  let path = GMSPath(fromEncodedPath: points) else {
                continue
            }
            let polyline = GMSPolyline(path: path)
            polyline.strokeColor = .systemPink
            polyline.strokeWidth = 5
            polyline.map = GMSmapView
            
            // Extend the bounds to include the polyline's path
            bounds = bounds.includingPath(path)
        }
        
        // Calculate the center of the bounds - GMSCoordinateBounds() doesn't have center field
        let centreLatitude = (bounds.northEast.latitude + bounds.southWest.latitude) / 2
        let centreLongitude = (bounds.northEast.longitude + bounds.southWest.longitude) / 2
        let centre = CLLocationCoordinate2D(latitude: centreLatitude, longitude: centreLongitude)
        
        // Move the camera to the center point
        let camera = GMSCameraUpdate.setTarget(centre, zoom: Float(preciseLocationZoomLevel))
        GMSmapView.animate(with: camera)
    }
    
    // MARK: - Using SwiftyJSON to manage and parse the returned JSON directions to find distance and thereby calculate the CO2 emissions; also saving down the polylines to a variable so it can be stored and drawn out at a future date.
    func calculateRouteDistanceAndEmissions(from json: [String: Any], forTransport transportMode: String) -> Double? {
            guard let routes = json["routes"] as? [[String: Any]] else {
                print("Routes not found in JSON")
                return nil
            }
            
            var totalDistance = 0.0
            var totalEmissions = 0.0
            var totalDuration = 0
            
            for route in routes {
                guard let legs = route["legs"] as? [[String: Any]], let firstLeg = legs.first else {
                    print("No legs found in route")
                    continue
                }
                
                // Calculate total distance and duration of the journey
                if let distanceDict = firstLeg["distance"] as? [String: Any], let distanceValue = distanceDict["value"] as? Double,
                    let durationDict = firstLeg["duration"] as? [String: Any], let durationValue = durationDict["value"] as? Int {
                    totalDistance += distanceValue
                    totalDuration += durationValue
                } else {
                    print("Invalid distance or duration format")
                    continue
                }
                
                // Iterate through each leg
                for leg in legs {
                    guard let steps = leg["steps"] as? [[String: Any]] else {
                        print("No steps found in leg")
                        continue
                    }
                    
                    // Iterate through each step in the leg
                    for step in steps {
                        guard let distanceDict = step["distance"] as? [String: Any],
                              let distanceValue = distanceDict["value"] as? Double,
                              let travelMode = step["travel_mode"] as? String else {
                            print("Invalid step format")
                            continue
                        }
                        
                        // Calculate emissions for non-walking and non-cycling steps
                        if travelMode != "WALKING" && travelMode != "CYCLING" {
                            var emissionFactor: Double
                            if let transitDetails = step["transit_details"] as? [String: Any],
                                let modeOfTransport = transitDetails["line"] as? [String: Any],
                                let vehicleType = modeOfTransport["vehicle"] as? [String: Any],
                                let mode = vehicleType["type"] as? String {
                                emissionFactor = calculateCarbonEmissions(for: mode)
                        } else {
                            // If no transit vehicle type found, assume a car
                            emissionFactor = calculateCarbonEmissions(for: "DRIVING")
                        }
                        let stepDistance = distanceValue / 1000 // Convert distance from meters to kilometers
                        totalEmissions += stepDistance * emissionFactor
                    }
                }
            }
        }
            
        print("Distance: \(totalDistance)m")
        print("Duration: \(totalDuration / 60) minutes")
        print("Emissions: \(totalEmissions)gCO2/km")
            
        return totalEmissions
    }
    // MARK: Calculate carbon emissions of light-duty vehicles (driving)
    func calculateCarbonEmissions(for mode: String) -> Double {
        // Constants for carbon emissions factors (gCO2/km)
        let carbonFactors: [String: Double] = [
            "WALKING": 0,
            "CYCLING": 0, // Walking and cycling have no emissions (assumed)
            "TRAIN": 28, // According to IrishRail 2020, per passenger km
            "BUS": 13.73, // Based on EURO VI bus model and assuming diesel usage, per passenger km
            "TRAM": 0, // sourcing of tram is unknown - no direct GHG released via electricity
            "DRIVING": 16
        ]
        
        // Calculate emissions based on mode of transport and distance
        if let emissionFactor = carbonFactors[mode] {
            return emissionFactor
        } else {
            print("No emission factor found for \(mode)")
            return 0
        }
    }
    
    @IBAction func saveRoute (_ sender: Any) {
        let realm = RealmManager.shared.getRealm()
        
        // Create a new Trip object
        let trip = Trip()
        
        // Set the destination and origin coordinates
        let destination = Location()
        destination.latitude = destinationCoordinate.latitude
        destination.longitude = destinationCoordinate.longitude
        // Set other destination properties as needed
        trip.destination = destination
        
        let origin = Location()
        origin.latitude = originCoordinate.latitude
        origin.longitude = originCoordinate.longitude
        // Set other origin properties as needed
        trip.origin = origin
        
        // Set the selected method of travel
        trip.methodOfTravel = transportMode.lowercased()
        
        // Create a new Emission object
        let emission = Emission()
        // Set the emission value, date, and link it to the trip
        if totalCarbonEmission != 0.0 {
            emission.value = Double(totalCarbonEmission)
        } else {
            print("Total carbon emission is nil")
            // Handle this error case, such as setting a default value or displaying an error message
            // For now, let's set a default value of 0.0
            emission.value = 0.0
        }
        emission.date = Date()
        trip.emissions.append(emission)
        
        // Create Location objects for origin and destination
        let originLocation = Location()
        originLocation.latitude = originCoordinate.latitude
        originLocation.longitude = originCoordinate.longitude
        
        let destinationLocation = Location()
        destinationLocation.latitude = destinationCoordinate.latitude
        destinationLocation.longitude = destinationCoordinate.longitude
        
        let routeInfo = RouteInfo()
        routeInfo.origin = originLocation
        routeInfo.destination = destinationLocation
        routeInfo.methodOfTravel = transportMode.lowercased()
        routeInfo.polylinePoints = points
        
        try! realm.write {
            // Set the routeInfo property of the trip
            trip.routeInfo = routeInfo
            
            // Add the routeInfo object to the Realm database
            realm.add(routeInfo)
            
            // Add the trip and emission objects to the Realm database
            realm.add(trip)
            realm.add(emission)
        }
        
        tripAddedDelegate?.didAddTrip(trip)
        print("Route saved successfully")
    }
}

// MARK: Allow communication so the table view can update when a new route is added to the DB
protocol TripAddedDelegate: AnyObject {
    func didAddTrip(_ trip: Trip)
}
