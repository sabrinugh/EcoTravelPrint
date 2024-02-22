//
//  MapViewController.swift
//  developing_v2
//
//  Created by Sabrina Boc on 05/02/2024.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, NetworkServiceDelegate {
    
    var mapView : GMSMapView!
    var placesClient: GMSPlacesClient!
    var preciseLocationZoomLevel: Float = 15.0
    var approximateLocationZoomLevel: Float = 10.0
    
    
    var sourceCoordinates = CLLocationCoordinate2D()
    var destinationCoordinates = CLLocationCoordinate2D()
    var didRequestRoute : Bool = false
    var destinationLocationRequest : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // Init the location manager
        initLocationManager()
        openMap()
    }
    // MARK: Set up the Core Location manager
    public func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    // MARK: Instantiating the map options and setting up the map view onto the page, directly setting the default camera position to Dublin City Centre via coordinates
    public func openMap() {
        let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
        let options = GMSMapViewOptions()
        // Set defauly coordinates to Co. Dublin, Ireland
        options.camera = GMSCameraPosition.camera(withLatitude: 53.3498, longitude: -6.2603, zoom: zoomLevel)
        options.frame = self.view.bounds

        mapView = GMSMapView(options: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true // Button to display current location
        self.view.addSubview(mapView)
    }
    
    // Check protocol for result of route request
    func didRouteRequest(result: String) {
        var temp = result
        temp.removeLast()
        let minutes = Int(temp)! / 60
        print(minutes)
        DispatchQueue.main.async() {
            print("It worked")
        }
    }
    
    // Setting variables for the location settings and thereby routes
    var locationManager = CLLocationManager()
    
    func getLocation () {
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
    
    var placeName = ""
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.delegate = nil
        locationManager.stopUpdatingLocation()
        let location = locations.first!
    
        // Based off authorisation settings, change zoom view
        let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        
        sourceCoordinates =  CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        if didRequestRoute {
            let calls = RouteRequests()
            calls.delegate = self
            //need to get new source before getting distance to destination
            if destinationLocationRequest {
                calls.postRoute(startCoordinates: sourceCoordinates, destinationCoordinates: destinationCoordinates)
            }
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    // Get coordinates from English written address
    func getCoordinates(for address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            guard let placemark = placemarks?.first, let location = placemark.location else {
                completion(nil)
                return
            }
            completion(location.coordinate)
        }
    }
    
    // Get coordinates from word address
    var placeID = ""
    func getLatLongFromPlaceId () {
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt64(GMSPlaceField.coordinate.rawValue) |
                                                  UInt64(GMSPlaceField.placeID.rawValue))
        
        placesClient?.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: nil, callback: {
          (place: GMSPlace?, error: Error?) in
          if let error = error {
            print("An error occurred: \(error.localizedDescription)")
            return
          }
          if let place = place {
            // self.lblName?.text = place.name
              print("The selected place coordinate is: \(place.coordinate)")
              self.destinationCoordinates = place.coordinate
              self.destinationLocationRequest = true
          }else{
              print("Already here");
          }
        })
    }
}

// MARK: Autocomplete the written address when searching up for a route
extension MapViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name ?? "placename")")
        print("Place ID: \(place.placeID ?? "")")
        print("Place attributions: \(String(describing: place.attributions))")
        self.placeID = place.placeID ?? "nil"
        self.getLatLongFromPlaceId()
        self.placeName = (place.name ?? "")
        /*DispatchQueue.main.async() {
            self.destinationLabel.text = place.name ?? ""
        }*/
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Fail")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        print("Cancelled")
    }
    
    
}
