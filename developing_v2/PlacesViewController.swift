//
//  PlacesViewController.swift
//  developing_v2
//
//  Created by Sabrina Boc on 05/03/2024.
//
/*
import UIKit
import GooglePlaces

class PlacesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var placesTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    private var tableDataSource: GMSAutocompleteTableDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        view.addSubview(searchBar)
        tableDataSource = GMSAutocompleteTableDataSource.init()
        tableDataSource.delegate = self
        
        placesTable.delegate = tableDataSource
        placesTable.dataSource = tableDataSource
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
            
        // Customize the cell with your data, for example:
        let rowData = tableDataSource[indexPath.row]
        cell.textLabel?.text = rowData // Assuming your data is of type String
            
        return cell
    }
}

extension PlacesViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    // Update the GMSAutocompleteTableDataSource with the search text.
    tableDataSource.sourceTextHasChanged(searchText)
  }
}

extension PlacesViewController: GMSAutocompleteTableDataSourceDelegate {
  func didUpdateAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        #if compiler(>=5.0)
        #warning("autocompleteResults is deprecated")
        #endif
      
      if let predictions = tableDataSource.autocompleteResults {
          // Iterate through predictions
          for prediction in predictions {
              // Access prediction data such as place ID, attributed primary text, and secondary text
              let placeID = prediction.placeID
              let primaryText = prediction.attributedPrimaryText.string
              let secondaryText = prediction.attributedSecondaryText?.string ?? ""
          }
      }
      placesTable.reloadData()
  }

  func didRequestAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
    // Reload table data.
      placesTable.reloadData()
  }

  func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace) {
    // Do something with the selected place.
      print("Place name: \(String(describing: place.name))")
      print("Place address: \(String(describing: place.formattedAddress))")
      print("Place attributions: \(String(describing: place.attributions))")
  }

  func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: Error) {
    // Handle the error.
    print("Error: \(error.localizedDescription)")
  }

  func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didSelect prediction: GMSAutocompletePrediction) -> Bool {
    return true
  }
}
*/
