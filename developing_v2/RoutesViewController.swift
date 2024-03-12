//
//  RoutesViewController.swift
//  developing_v2
//
//  Created by Sabrina Boc on 06/03/2024.
//

import UIKit
import GooglePlaces
import GoogleMaps
import CoreLocation
import Alamofire
import SwiftyJSON

class RoutesViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var mapView: UIView!
    
    var locationManager: CLLocationManager!
    var permissionFlag: Bool!
    var currentLocation: CLLocation!
    var googleMaps: GMSMapView!
    var polylineArray: [GMSPolyline] = []
    
    var transferPolyline: String!
    var pickupCoordinate: CLLocationCoordinate2D!
    var geocoder: GMSGeocoder!
    var city: String!
    var address: String!
    
    var originCoords : CLLocationCoordinate2D!
    var destinationCoords : CLLocationCoordinate2D!
    
    var preciseLocationZoomLevel: Float = 15.0
    var approximateLocationZoomLevel: Float = 10.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        city = ""
        address = ""
        geocoder = GMSGeocoder()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Hard coding test coordinates
        //var originCoords: CLLocationCoordinate2D!
        //var destinationCoords: CLLocationCoordinate2D!
        let lat1: Double = 53.353600
        let long1: Double = -6.278255
        let lat2: Double = 53.348734
        let long2: Double = -6.286066
        let originCoords = CLLocationCoordinate2D(latitude: lat1, longitude: long1)
        let destinationCoords = CLLocationCoordinate2D(latitude: lat2, longitude: long2)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse{
            self.permissionFlag = true
            googleMaps = openMap()
            view.addSubview(googleMaps)
            
        }else{
            self.permissionFlag = false
        }
    }
    
    private func openMap() -> GMSMapView {
        let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
        let options = GMSMapViewOptions()
        // Set defauly coordinates to Co. Dublin, Ireland
        options.camera = GMSCameraPosition.camera(withLatitude: 53.3498, longitude: -6.2603, zoom: zoomLevel)
        options.frame = self.view.bounds
        
        googleMaps = GMSMapView(options: options)
        googleMaps.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        googleMaps.isMyLocationEnabled = true
        googleMaps.settings.myLocationButton = true // Button to display current location
        
        return googleMaps
    }
    
    
    func getLocation () {
        let manager = CLLocationManager()
        locationManager.delegate = self
        // If permissions are given to use device location
        if (manager.authorizationStatus == .authorizedWhenInUse)
            || (manager.authorizationStatus == .authorizedAlways) {
            print("Location authorised")
            locationManager.startUpdatingLocation()
        } else{
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
                                if self.googleMaps != nil
                                {
                                    let bounds = GMSCoordinateBounds(path: path!)
                                    self.googleMaps!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
                                }
                            }else{
                                polyline.strokeColor = UIColor.lightGray
                                polyline.strokeWidth = 4
                            }
                            
                            self.polylineArray.append(polyline)
                            polyline.map = self.googleMaps
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
                            if self.googleMaps != nil
                            {
                                let bounds = GMSCoordinateBounds(path: polylineArray[i].path!)
                                self.googleMaps!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
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
            googleMaps.camera = camera
            googleMaps.mapType = .normal
            geocoder.reverseGeocodeCoordinate(CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude), completionHandler: {
                response, error in
                if error == nil{
                    if let resultAdd = response?.firstResult(){
                        self.googleMaps.delegate = self
                        let lines = resultAdd.lines! as [String]
                        print("ADDRESS => \(lines.joined(separator: "\n"))")
                        let marker = GMSMarker()
                        marker.position = CLLocationCoordinate2D(latitude: self.currentLocation.coordinate.latitude, longitude: self.currentLocation.coordinate.longitude)
                        marker.snippet = lines.joined(separator: "\n")
                        marker.title = "\(resultAdd.locality ?? "Unavailable")"
                        marker.map = self.googleMaps
                    }else{
                        print("ERROR_PLEASE_TRY_AGAIN_LATER")
                    }
                    
                }
            })
        } else{
           print("CURRENT_LOCATION_OBJECT_IS_NIL")
        }
    }
}
