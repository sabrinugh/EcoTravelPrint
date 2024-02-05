//
//  ViewController.swift
//  developing_v2
//
//  Created by Sabrina Boc on 05/02/2024.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func openMapView(_ sender: Any) {
        let vc = MapViewController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil);
    }
    

}

