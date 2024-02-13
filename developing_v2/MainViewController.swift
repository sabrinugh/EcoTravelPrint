//
//  MainViewController.swift
//  developing_v2
//
//  Created by Sabrina Boc on 05/02/2024.
//

import UIKit
import GoogleMaps

class MainViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    
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
    
    @IBOutlet weak var mapViewSub: UIView!
    
    
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

