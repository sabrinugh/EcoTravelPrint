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
import Alamofire
import SwiftyJSON

// ass NetworkServiceDelegate into the class
class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UITextFieldDelegate {
    var mapView: GMSMapView!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    var pickupCoordinate: CLLocationCoordinate2D!
    var originCoords: CLLocationCoordinate2D!
    var destinationCoords: CLLocationCoordinate2D!
    var transferPolyline: String?
    var polylineArray: [GMSPolyline] = []
    var geocoder: GMSGeocoder! // Convert written location to long-lat coords
    var permissionFlag: Bool!
    
    
    @IBOutlet weak var sourceTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    
    var preciseLocationZoomLevel: Float = 15.0
    var approximateLocationZoomLevel: Float = 10.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // Initialise the location manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
            }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse{
            self.permissionFlag = true
            openMap()
            
        }else{
           self.permissionFlag = false
            openMap()
        }
    }
    
    // MARK: Instantiating the map options and setting up the map view onto the page. Directly setting the default camera position to Dublin City Centre via coordinates
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
        self.currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    
    @objc func placeApiVC(){
        let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RoutesViewController") as! RoutesViewController
        self.present(VC, animated: true)
    }

    
    // MARK: Drawing the requested route between the origin and destination locations
    public func drawRoute() {
        if permissionFlag {
            let origin  = "\(self.originCoords.latitude),\(self.originCoords.longitude)"
            let destination = "\(self.destinationCoords.latitude),\(self.destinationCoords.longitude)"
            let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&alternatives=true&key=AIzaSyA34PSy0Cpr20op5PwVpdhSMOWpPiFMuv0"
            
            Alamofire.request(url).responseJSON(completionHandler: {
                Response in
                if Response.result.isSuccess {
                    do{
                        let json =  try JSON(data: Response.data!)
                        let routes = json["routes"].arrayValue
                        print(json)
                        for i in 0 ..< routes.count{
                            let route = routes[i]
                            let routeOverviewPolyline = route["overview_polyline"].dictionary
                            let points = routeOverviewPolyline?["points"]?.stringValue
                            let path = GMSPath.init(fromEncodedPath: points!)
                            let polyline = GMSPolyline.init(path: path)
                            polyline.isTappable = true
                            if i == 0{
                                polyline.strokeColor = UIColor.systemPink
                                polyline.strokeWidth = 5
                                self.transferPolyline = points // SAVE THESE POINTS THEY ARE ENCODED LAT LONGS OF SUGGESTED ROUTES
                                if self.mapView != nil
                                {
                                    let bounds = GMSCoordinateBounds(path: path!)
                                    self.mapView!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
                                }
                            }else{
                                polyline.strokeColor = UIColor.lightGray
                                polyline.strokeWidth = 4
                            }
                            
                            self.polylineArray.append(polyline)
                            polyline.map = self.mapView
                        }
                        
                    }catch{
                        print("ERROR")
                    }
                    
                }else{
                    
                }
            })
        }else {
            if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted{
                //redirectToSettings()
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        if permissionFlag{
            if overlay.isKind(of: GMSPolyline.self){
                mapView.clear()
                for i in 0 ..< self.polylineArray.count{
                    
                    if overlay == polylineArray[i]{
                        if polylineArray[i].strokeColor == UIColor.blue{
                            //ALREADY SELECTED ROUTES
                            print("ALREADY_SELECTED")
                            polylineArray[i].map = mapView
                        }else{
                            //SELECTING ROUTE
                            polylineArray[i].strokeColor = UIColor.systemPink
                            polylineArray[i].strokeWidth = 5
                            polylineArray[i].map = mapView
                            self.transferPolyline = polylineArray[i].path?.encodedPath()
                            if self.mapView != nil
                            {
                                let bounds = GMSCoordinateBounds(path: polylineArray[i].path!)
                                self.mapView!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
                            }
                            print("TransferPolyline => \(transferPolyline ?? "nil")")
                        }
                    }else{
                        //UNSELECTING ROUTE
                        polylineArray[i].strokeColor = UIColor.lightGray
                        polylineArray[i].strokeWidth = 4
                        polylineArray[i].map = mapView
                    }
                }
            }
        }else{
            if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted{
                redirectToSettings()
            }
        }
    }
    
    public func redirectToSettings() {
        self.pickupCoordinate = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        if pickupCoordinate != nil{
            
                let camera = GMSCameraPosition.camera(withLatitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, zoom: 15.0)
                mapView.camera = camera
            mapView.mapType = .normal
            geocoder.reverseGeocodeCoordinate(CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude), completionHandler: {
                response, error in
                if error == nil{
                    if let resultAdd = response?.firstResult(){
                        self.mapView.delegate = self
                        let lines = resultAdd.lines! as [String]
                        print("ADDRESS => \(lines.joined(separator: "\n"))")
                        let marker = GMSMarker()
                        marker.position = CLLocationCoordinate2D(latitude: self.currentLocation.coordinate.latitude, longitude: self.currentLocation.coordinate.longitude)
                        marker.snippet = lines.joined(separator: "\n")
                        marker.title = "\(resultAdd.locality ?? "Unavailable")"
                        marker.map = self.mapView
                    }else{
                        print("ERROR_PLEASE_TRY_AGAIN_LATER")
                    }
                    
                }
            })
        } else{
           print("CURRENT_LOCATION_OBJECT_IS_NIL")
        }
    }
    
    @objc func autocompleteClicked(_ sender: UITextField) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self

        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt64(UInt(GMSPlaceField.name.rawValue) | UInt(GMSPlaceField.placeID.rawValue)))
        autocompleteController.placeFields = fields

        // Specify a filter for the autosearch - maybe add in the locality?
        let filter = GMSAutocompleteFilter()
        autocompleteController.autocompleteFilter = filter

        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
      }
    
    
    @IBAction func insertOrigin(_ sender: Any) {
        sourceTextField.addTarget(self, action: #selector(autocompleteClicked), for: .touchUpInside)
        self.view.addSubview(sourceTextField)
    }
    func makeButton() {
        let btnLaunchAc = UIButton(frame: CGRect(x: 5, y: 150, width: 300, height: 35))
        btnLaunchAc.backgroundColor = .blue
        btnLaunchAc.setTitle("Launch autocomplete", for: .normal)
        btnLaunchAc.addTarget(self, action: #selector(autocompleteClicked), for: .touchUpInside)
        self.view.addSubview(btnLaunchAc)
      }
}

extension MapViewController: GMSAutocompleteViewControllerDelegate {

  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
      print("Place name: \(String(describing: place.name))")
      print("Place ID: \(String(describing: place.placeID))")
      print("Place attributions: \(String(describing: place.attributions))")
    dismiss(animated: true, completion: nil)
  }

  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }

  // User canceled the operation.
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    dismiss(animated: true, completion: nil)
  }
}
