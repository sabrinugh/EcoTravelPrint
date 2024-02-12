//
//  MainViewController.swift
//  developing_v2
//
//  Created by Sabrina Boc on 05/02/2024.
//

import UIKit
import GoogleMaps

class MainViewController: UIViewController {    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //loadMapView()
    }
    
    @IBOutlet weak var mapViewSub: UIView!
    /* Create the map View and add the Google Map into the UIView element. Load in any additional buttons onto the map view as self.view.addSubview() */
    /*private func loadMapView() {
        let options = GMSMapViewOptions()
        options.camera = GMSCameraPosition.camera(withLatitude: 53.34, longitude: 6.20, zoom: 6.0)
        options.frame = mapViewSub.bounds

        let mapView = GMSMapView(options: options)
        view.addSubview(mapView)
    }*/
    
    private func loadnavBar() {
    }
    
    private func loadSearchBar() {
        
    }
    
    @IBOutlet weak var testButton: UIButton!
    private func loadTestButton() {
    
    }
    

}

