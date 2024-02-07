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
        
        /*
            Instantiating the map options and setting up the map view onto the page
            Directly setting the default camera position to Dublin City Centre via coordinates
        */
        self.openMap();
        
    }
    
    func openMap() {
        let options = GMSMapViewOptions()
        options.camera = GMSCameraPosition.camera(withLatitude: 53.34, longitude: 6.20, zoom: 6.0)
        options.frame = self.view.bounds

        let mapView = GMSMapView(options: options)
        self.view.addSubview(mapView)
    }
    
    @IBAction func OpenHomePage(_ sender: Any) {
        let vc = ViewController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil);
    }
    
}
