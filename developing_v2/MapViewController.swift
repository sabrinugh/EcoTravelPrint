//
//  MapViewController.swift
//  developing_v2
//
//  Created by Sabrina Boc on 05/02/2024.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad();
        openMap();
        
    }
    
    /*
    Instantiating the map options and setting up the map view onto the page
    Directly setting the default camera position to Dublin City Centre via coordinates
    */
    private func openMap() {
        let options = GMSMapViewOptions()
        options.camera = GMSCameraPosition.camera(withLatitude: 53.3498, longitude: -6.2603, zoom: 8.0)
        options.frame = self.view.bounds

        let mapView = GMSMapView(options: options)
        self.view.addSubview(mapView)
    }
    
}
