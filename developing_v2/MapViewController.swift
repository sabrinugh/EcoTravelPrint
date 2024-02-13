//
//  MapViewController.swift
//  developing_v2
//
//  Created by Sabrina Boc on 05/02/2024.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController, CLLocationManagerDelegate{
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var mapView : GMSMapView!
    var placesClient: GMSPlacesClient!
    var preciseLocationZoomLevel: Float = 15.0
    var approximateLocationZoomLevel: Float = 10.0
    
    override func viewDidLoad() {
        super.viewDidLoad();
        initLocationManager();
        openMap();
        
    }
    
    private func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    /*
    Instantiating the map options and setting up the map view onto the page
    Directly setting the default camera position to Dublin City Centre via coordinates
    */
    public func openMap() {
        let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
        let options = GMSMapViewOptions()
        // Set defauly coordinates to Co. Dublin, Ireland
        options.camera = GMSCameraPosition.camera(withLatitude: 53.3498, longitude: -6.2603, zoom: zoomLevel)
        options.frame = self.view.bounds

        mapView = GMSMapView(options: options)
        mapView.settings.myLocationButton = true // Button to display current location
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        self.view.addSubview(mapView)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last! // FInd last known location
        print("Location: \(location)") // print to console
        
        // Based off authorisation settings, change zoom view
        let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
    }
    
    
    // Deal with the permissions for accessing the user's current location
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let accuracy = manager.accuracyAuthorization
        switch accuracy {
        case .fullAccuracy:
            print("Location accuracy is precise.")
        case .reducedAccuracy:
            print("Location accuracy is not precise.")
        @unknown default:
            fatalError()
        } // end switch
        
        switch status {
        case .restricted:
            print("Location accuracy has been restricted")
        case .denied:
            print("Location denied")
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        @unknown default:
            fatalError()
        } // end switch
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
