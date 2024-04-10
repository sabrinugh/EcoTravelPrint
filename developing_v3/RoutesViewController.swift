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

    @IBOutlet weak var TextField: UITextField!
    
    var selectedFromDestination: CLLocationCoordinate2D?
    var selectedToDestination: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("IN ROUTESVIEWCONTROLLER")
        // searchRoute(origin: originCoordinate, destination: destinationCoordinate)
    }
    
    func searchRoute(origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        let apiKey = "AIzaSyA34PSy0Cpr20op5PwVpdhSMOWpPiFMuv0"
        let originString = "\(origin.latitude),\(origin.longitude)"
        let destinationString = "\(destination.latitude),\(destination.longitude)"
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(originString)&destination=\(destinationString)&key=\(apiKey)")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                // Parse the JSON response and extract route information
                // Handle the route information (e.g., draw route on map)
                print("JSON Response: \(json ?? [:])")
                print("OriginString: ", originString)
                print("DestinationString: ", destinationString)
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    

}
