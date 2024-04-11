//
//  ViewController.swift
//  developing_v3
//
//  Created by Sabrina Boc on 24/03/2024.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var originTextInput: UITextField!
    @IBOutlet weak var destinationTextInput: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var mapView: UIView!

    @IBOutlet weak var carSelect: UIButton!
    @IBOutlet weak var walkSelect: UIButton!
    @IBOutlet weak var cycleSelect: UIButton!
    @IBOutlet weak var transitSelect: UIButton!
    var modeTransport = ""
    
    var originCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    
    var geocoder: CLGeocoder!
    
    var GMSmapView: GMSMapView!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation! // Pick up the general vicinity of a user based on location settings
    
    var approximateLocationZoomLevel = 10
    var preciseLocationZoomLevel = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        
        openMap()
    }
    
    // MARK: Requesting user agreement for using current location & checking if adequate authorisation has been given for the GPS location
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
    
    // MARK: Allow user input via textFields or buttons for route searching
    @IBAction func originGeocode(_ sender: Any) {
    }
    
    @IBAction func destinationGeocode(_ sender: Any) {
    }
    @IBAction func carButtonTapped(_ sender: UIButton) {
        self.modeTransport = "driving"
    }
    
    @IBAction func walkButtonTapped(_ sender: UIButton) {
        self.modeTransport = "walking"
    }
    @IBAction func cycleButtonTapped(_ sender: UIButton) {
        self.modeTransport = "cycling"
    }
    @IBAction func transitButtonTapped(_ sender: UIButton) {
        self.modeTransport = "transit"
    }
    
    // MARK: Geocoding using Core Location
    func initGeocodeSearch(_ textField: UITextField, completionHandler: @escaping (CLLocationCoordinate2D?, Error?) -> Void) {
        textField.resignFirstResponder()
        let locationName = textField.text ?? ""
        geocodeLocation(locationName: locationName) { coordinate, error in
            if let error = error {
                print(error)
                completionHandler(nil, error)
            } else {
                completionHandler(coordinate, nil)
            }
        }
    }

    func geocodeLocation(locationName: String, completionHandler: @escaping (CLLocationCoordinate2D?, Error?) -> Void) {
        getCoordinate(addressString: locationName) { coordinate, error in
            if let error = error {
                print(error)
                completionHandler(nil, error)
            } else {
                completionHandler(coordinate, nil)
            }
        }
    }

    func getCoordinate(addressString: String, completionHandler: @escaping (CLLocationCoordinate2D?, NSError?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if let error = error {
                completionHandler(nil, error as NSError)
                return
            }
                
            guard let placemark = placemarks?.first else {
                let error = NSError(domain: "developing_v3", code: 0, userInfo: [NSLocalizedDescriptionKey: "No placemarks found"])
                completionHandler(nil, error)
                return
            }
                
            let location = placemark.location
            let coordinate = location?.coordinate
            completionHandler(coordinate, nil)
        }
    }

    // MARK: Take the geocoded coordiantes (CLLocationCoordinate2D and send it to a new view controller for searching the routes when the search button is pressed.
    @IBAction func searchRoute(_ sender: UIButton) {
        // Obtain the coordinates for origin and destination
        initGeocodeSearch(originTextInput) { originCoordinate, originError in
            if let originCoordinate = originCoordinate {
                self.initGeocodeSearch(self.destinationTextInput) { destinationCoordinate, destinationError in
                    if let destinationCoordinate = destinationCoordinate {
                        // Instantiate the new view controller
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                            
                        // Instantiate the RoutesViewController from the storyboard
                        if let vc = storyboard.instantiateViewController(withIdentifier: "RoutesViewController") as? RoutesViewController {
                            // Pass the coordinates to the new view controller
                            vc.originCoordinate = originCoordinate
                            vc.destinationCoordinate = destinationCoordinate
                            if self.modeTransport != "" {
                                vc.transportMode = self.modeTransport
                            } else{
                                vc.transportMode = "driving" // set driving as default - normal for URL request
                            }
                            // Present the new view controller modally
                            self.present(vc, animated: true, completion: nil)
                        }
                        
                    } else if let destinationError = destinationError {
                        print("Error obtaining destination coordinates: \(destinationError.localizedDescription)")
                    }
                }
            } else if let originError = originError {
                print("Error obtaining origin coordinates: \(originError.localizedDescription)")
            }
        }
    }
}

