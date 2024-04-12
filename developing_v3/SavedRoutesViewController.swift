import UIKit
import GoogleMaps
import RealmSwift

class SavedRoutesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TripDeletionDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var savedTrips: Results<SavedTrips>?
        let realm = RealmManager.shared.getRealm()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Fetch SavedTrips data from Realm
            savedTrips = realm.objects(SavedTrips.self)
            
            // Configure table view
            tableView.dataSource = self
            tableView.delegate = self
        }
        
        // MARK: UITableViewDataSource Methods
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if let savedTrips = savedTrips, !savedTrips.isEmpty {
                return savedTrips.count
            } else {
                // Return 1 row for "No saved routes" message
                return 1
            }
        }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RouteCell", for: indexPath) as! CellViewTemplate
        
        if let savedTrip = savedTrips?[indexPath.row], let emission = savedTrip.trip?.emissions.first {
            let formattedEmissions = String(format: "%.3f", emission.value)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy" // Customize the date format as needed
            let formattedDate = dateFormatter.string(from: emission.date)
            
            // Configure cell with emission value and date
            cell.carbonEmissions.text = "\(formattedEmissions)"
            cell.dateVar.text = "\(formattedDate)"
        } else {
            // Handle the case where savedTrip or emission is nil
            cell.carbonEmissions.text = "No emission data available"
            cell.dateVar.text = "No date available"
        }
        return cell
        
    }
    
    // MARK: Open trip and disply all relevant details
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let savedTrips = savedTrips else {
            print("savedTrips is nil")
            return
        }
            
        guard indexPath.row < savedTrips.count else {
            print("Index out of bounds")
            return
        }
        let selectedTrip = savedTrips[indexPath.row]
        // Instantiate the new view controller
        let vc = TripDetailsViewController()
        vc.delegate = self
        vc.trip = selectedTrip.trip
        navigationController?.pushViewController(vc, animated: true) // Open a nav controller where we can easily go back
    }
    
    // Update the table view when RoutesViewController saves a new route.
    func didAddTrip(_ trip: Trip) {
        // Update savedTrips array
        savedTrips = realm.objects(SavedTrips.self)
        
        // Reload table view to reflect changes
        tableView.reloadData()
    }
    
    func deleteTrip(_ tripID: String) {
        if let tripToDelete = savedTrips?.filter("trip.id == %@", tripID).first {
            try! realm.write {
                realm.delete(tripToDelete) // delete trip
            }
            // Reload table view to reflect changes
            tableView.reloadData()
        }
    }
}

protocol TripDeletionDelegate: AnyObject {
    func deleteTrip(_ tripID: String)
}


    
