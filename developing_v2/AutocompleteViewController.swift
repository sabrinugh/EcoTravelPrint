//
//  AutocompleteViewController.swift
//  developing_v2
//
//  Created by Sabrina Boc on 12/03/2024.
//

import UIKit
import GooglePlaces

class AutocompleteViewController: UIViewController {
    override func viewDidLoad() {
        
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
}

extension AutocompleteViewController: GMSAutocompleteViewControllerDelegate {

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

  // Turn the network activity indicator on and off again.
  func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
  }

  func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
  }
}
