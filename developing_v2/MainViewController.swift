//
//  MainViewController.swift
//  developing_v2
//
//  Created by Sabrina Boc on 05/02/2024.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MainViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapViewSub: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        locationManager.delegate = self;
        if CLLocationManager.locationServicesEnabled(){
            locationManager.requestLocation();
        } else {
            locationManager.requestWhenInUseAuthorization();
        }
        */
    }
    
    private func loadnavBar() {
    }
    
    private func loadSearchBar() {
        
    }
    
    @IBAction func testButton(_ sender: Any) {
        let vc = MapViewController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil);
    }
    

}

