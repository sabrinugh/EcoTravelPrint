//
//  TripDetailsViewController.swift
//  developing_v3
//
//  Created by Sabrina Boc on 30/03/2024.
//

import UIKit
import RealmSwift
import GoogleMaps

class TripDetailsViewController: UIViewController, CLLocationManagerDelegate {
    var trip: Trip?
    
    @IBOutlet weak var vertStack: UIStackView!
    @IBOutlet weak var carbonVar: UILabel!
    @IBOutlet weak var distanceVar: UILabel!
    @IBOutlet weak var durationVar:UILabel!
    @IBOutlet weak var dateVar: UILabel!
    
    @IBOutlet weak var carbonLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    weak var delegate: TripDeletionDelegate? // Add delegate property
    
    // Map related items
    var GMSmapView: GMSMapView!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation! // Pick up the general vicinity of a user based on location settings
    var approximateLocationZoomLevel = 10
    var preciseLocationZoomLevel = 15
    @IBOutlet weak var mapView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        
//        openMap()
        if let trip = trip {
            // Extract information from the Trip object
            if let emissions = trip.emissions.first {
                self.carbonVar.text = "\(String(format: "%.2f", emissions.value)) gCO2/km"
                self.dateVar.text = formatDate(emissions.date)
            }
            if let routeInfo = trip.routeInfo {
                self.distanceVar.text = "\(String(format: "%.2f", routeInfo.distance/1000)) km"
                self.durationVar.text = "\(routeInfo.duration/60) minutes"
                if let polylinePoints = routeInfo.polylinePoints {
//                    drawRouteOnMap(polylinePoints: polylinePoints)
                } else {
                    print("Polyline points not available")
                }
            }
        }
    }
    
    // Format the date for display
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    // MARK: Location settings yay
    func getLocation() {
        let manager = CLLocationManager()
        locationManager.delegate = self
        // If permissions are given to use device location
        if (manager.authorizationStatus == .authorizedWhenInUse)
            || (manager.authorizationStatus == .authorizedAlways) {
            print("Location authorised")
            locationManager.startUpdatingLocation()
        }else{
            print("Location not authorised")
            locationManager.requestWhenInUseAuthorization() // Ask user for permission
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    print("Location permission granted")
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error with locationManager: \(error)")
    }
    
    // MARK: Open the GMSMap into the stackView
    public func openMap() {
        if locationManager.accuracyAuthorization == .fullAccuracy {
            print("Precise location")
        }
        else {
            print("Inaccurate location")
        }
        let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
        let options = GMSMapViewOptions()
        // Set default coordinates to Co. Dublin, Ireland
        options.camera = GMSCameraPosition.camera(withLatitude: 53.3498, longitude: -6.2603, zoom: Float(zoomLevel))
        
        if let mapView = mapView {
            options.frame = mapView.bounds
        } else {
            // Handle the case where mapView is nil
            print("Error: mapView is nil")
        }
                
        GMSmapView = GMSMapView(options: options)
        GMSmapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        GMSmapView.isMyLocationEnabled = true
        GMSmapView.settings.myLocationButton = true // Button to display current location

        self.mapView.addSubview(GMSmapView)
    }
    
    @IBAction func deleteRoute(_ sender: UIButton) {
        
        if let tripID = trip?.id {
            delegate?.deleteTrip(tripID)
            // Dismiss or navigate back after deletion
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: Draw out the route again on the map using the saved Trip polylines
    func drawRouteOnMap(polylinePoints: String) {
        guard !polylinePoints.isEmpty else {
            print("Polyline points are empty")
            return
        }
        
        let path = GMSPath(fromEncodedPath: polylinePoints)
        guard let validPath = path else {
            print("Invalid polyline points")
            return
        }
        
        let polyline = GMSPolyline(path: validPath)
        polyline.strokeColor = .systemPink
        polyline.strokeWidth = 5
        polyline.map = GMSmapView
        
        // Calculate bounds to center and zoom the map appropriately
        var bounds = GMSCoordinateBounds()
        for i in 0..<validPath.count() {
            bounds = bounds.includingCoordinate(validPath.coordinate(at: i))
        }
        let cameraUpdate = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
        GMSmapView.animate(with: cameraUpdate)
    }
}

