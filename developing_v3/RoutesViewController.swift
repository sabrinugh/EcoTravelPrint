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
    
    var locationManager: CLLocationManager!
    var preciseLocationZoomLevel = 10
    var approximateLocationZoomLevel = 20
    var GMSmapView: GMSMapView!
    
    var originCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    var transportMode: String = ""
    var totalCarbonEmission: Float = 0.00
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
                    
                    calculateTotalDistance(from: json ?? [:])
                    self.displayRouteOnMap(json: json ?? [:]) // Call to display the route
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
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
    
    // MARK: - Using SwiftyJSON to manage and parse the returned JSON directions to find distance and thereby calculate the CO2 emissions; also saving down the polylines to a variable so it can be stored and drawn out at a future date.
    func calculateTotalDistance(from json: [String: Any]) {
        // Check if the JSON contains the "routes" array
        guard let routes = json["routes"] as? [[String: Any]] else {
            print("Routes not found in JSON")
            return
        }
        
        var totalDistance = 0 // Change let to var to make it mutable
        var emissionsByTransport: [String: Double] = [:]
        
        // Extract polyline points from the first route
        if let route = routes.first,
            let routeOverviewPolyline = route["overview_polyline"] as? [String: Any],
            let points = routeOverviewPolyline["points"] as? String {
            self.points = points // To save into DB
        } else {
            print("Polyline points not found in JSON")
        }
        
        for route in routes {
            guard let legs = route["legs"] as? [[String: Any]] else {
                print("No legs found in route")
                continue
            }
            
            // Iterate through each leg
            for leg in legs {
                guard let modeOfTransport = leg["travel_mode"] as? String,
                      let distance = (leg["distance"] as? [String: Any])?["value"] as? Double else {
                    print("Invalid leg format")
                    continue
                }
                
                // Calculate carbon emissions for the leg
                let carbonEmissions = calculateCarbonEmissions(modeOfTransport: modeOfTransport, distance: distance / 1000) // Convert distance from meters to kilometers
                
                // Update total distance and emissions by transport
                totalDistance += Int(distance)
                emissionsByTransport[modeOfTransport, default: 0] += carbonEmissions
                
                // Print the results
                print("Transit Type: \(modeOfTransport), Distance: \(distance) meters, Carbon Emissions: \(carbonEmissions) gCO2")
            }
        }

        // Print total distance and emissions by transport
        print("Total Distance: \(totalDistance) meters")
        print("Emissions by Transport:")
        for (transport, emissions) in emissionsByTransport {
            print("- \(transport): \(emissions) gCO2")
        }
    }
    
    // MARK: Using the searched routes given polyline, display it on the map to user
    func displayRouteOnMap(json: [String: Any]) {
        guard let routes = json["routes"] as? [[String: Any]] else {
            print("Routes not found in JSON")
            return
        }

        var bounds = GMSCoordinateBounds()

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
    
    // MARK: Calculate carbon emissions of light-duty vehicles (driving)
    func calculateCarbonEmissions(modeOfTransport: String, distance: Double) -> Double {
        // Constants for carbon emissions factors (gCO2/km)
        let carbonFactors: [String: Double] = [
            "WALKING": 0,
            "CYCLING":0, // Walking and cycling have no emissions (assumed)
            "TRAIN": 28, // According to IrishRail 2020, per passenger km
            "BUS": 13.73, // Based on EURO VI bus model and assuming diesel usage, per passenger km
            "TRAM": 35, // sample, need change
            "DRIVING": 6
        ]
        
        // Calculate emissions based on mode of transport and distance
        guard let carbonFactor = carbonFactors[modeOfTransport] else {
            print("Invalid mode of transport: \(modeOfTransport)")
            return 0
        }
        
        return carbonFactor * distance
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
        emission.value = Double(totalCarbonEmission)
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

        // Begin a write transaction
        try! realm.write {
            // Set the routeInfo property of the trip
            trip.routeInfo = routeInfo
            
            // Add the routeInfo object to the Realm database
            realm.add(routeInfo)
            
            // Add the trip and emission objects to the Realm database
            realm.add(trip)
            realm.add(emission)
        }
        print("Route saved successfully")
    }
}
