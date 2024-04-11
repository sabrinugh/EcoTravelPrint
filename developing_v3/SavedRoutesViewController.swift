import UIKit
import GoogleMaps
import RealmSwift

class SavedRoutesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var trips: Results<Trip>?
    let realm = RealmManager.shared.getRealm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up table view
        tableView.dataSource = self
        tableView.delegate = self
        
        // Register custom cell
        tableView.register(cellViewTemplate.self, forCellReuseIdentifier: "tripCell")
        
        // Retrieve trip data from Realm
        trips = realm.objects(Trip.self)
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "tripCell", for: indexPath) as? cellViewTemplate else {
            return UITableViewCell()
        }
            
        if let trip = trips?[indexPath.row] {
            // Assuming you have access to the emission value and destination name
            let emissionValue = trip.emissions.first?.value ?? 0.0 // Assuming emission value is stored in the first emission object
            let destinationName = trip.destination?.name ?? "Unknown" // Assuming destination name is stored in a property called "name"

            // Update the text fields in the cell
            cell.carbonEmissions.text = "\(emissionValue) gCO2"
            cell.destinationVar.text = destinationName
        }
        return cell
    }
    
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect the selected row
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Open a new view controller
        if let trip = trips?[indexPath.row] {
            let tripDetailsVC = TripDetailsViewController()
            tripDetailsVC.trip = trip // Pass the selected trip to the new view controller
            
            // Push the new view controller onto the navigation stack
            navigationController?.pushViewController(tripDetailsVC, animated: true)
        }
    }
}
