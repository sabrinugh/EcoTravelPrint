//
//  RoutesViewController.swift
//  developing_v3
//
//  Created by Sabrina Boc on 29/03/2024.
//

import UIKit
import GooglePlaces
import GoogleMaps
import CoreLocation
import Alamofire
import SwiftyJSON

class RoutesViewController: ViewController {
//    var originCoordinate: CLLocationCoordinate2D?
//    var destinationCoordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let originCoordinate = originCoordinate {
            print("Origin: Latitude \(originCoordinate.latitude), Longitude \(originCoordinate.longitude)")
        } else {
            print("Origin coordinate is nil")
        }
                
        // Safely unwrap and print the destination coordinate
        if let destinationCoordinate = destinationCoordinate {
            print("Destination: Latitude \(destinationCoordinate.latitude), Longitude \(destinationCoordinate.longitude)")
        } else {
            print("Destination coordinate is nil")
        }
        
        print("IN ROUTESVIEWCONTROLLER")
    }
}
