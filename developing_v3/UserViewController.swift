//
//  UserViewController.swift
//  developing_v3
//
//  Created by Sabrina Boc on 12/04/2024.
//

import UIKit
import RealmSwift

class UserViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITableViewDelegate {
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var weeklyEmissions: UILabel!
    
    let realm = RealmManager.shared.getRealm()
    var searchedTrips: Results<SearchedTrips>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        userProfileImage.isUserInteractionEnabled = true
        userProfileImage.addGestureRecognizer(tapGestureRecognizer)
        
        var totalEmissions = calculateTotalEmissionsLastWeek()
        weeklyEmissions.text = String(totalEmissions)
        
        
        searchedTrips = realm.objects(SearchedTrips.self)
        
    }
    
    func calculateTotalEmissionsLastWeek() -> Double {
        // Calculate the date one week ago from today
        let oneWeekAgo = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
        
        // Query for all saved trips within the last week
        let savedTripsLastWeek = realm.objects(SavedTrips.self).filter("trip.emissions.date > %@", oneWeekAgo)
        
        // Sum up the emission values for trips within the last week
        let totalEmissionsLastWeek = savedTripsLastWeek.reduce(0.0) { (total, savedTrip) in
            if let emission = savedTrip.trip?.emissions.first {
                return total + emission.value
            }
            return total
        }
        return totalEmissionsLastWeek
    }
    
    // Using Objective-C to handle gestures
    @objc func imageTapped() {
        // Create an image picker controller
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
            
        // Present the image picker
        present(imagePicker, animated: true, completion: nil)
    }
    
    // Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                // Set the selected image to the image view
                userProfileImage.image = pickedImage
                
                // Save the selected image to Realm database
                saveImageToRealm(image: pickedImage)
            }
            
            // Dismiss the image picker
            picker.dismiss(animated: true, completion: nil)
        }
    
    // It's self-explanatory
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Using Realm to note down user profile picture and display it back if it exists - maybe add username editing too?
    func saveImageToRealm(image: UIImage) {
        guard let imageData = image.pngData() else {
            return // Failed to convert image to data
        }
        do {
            try realm.write {
                if let existingUserObject = realm.objects(User.self).first {
                    // Update the existing image object with the new image data
                    existingUserObject.imageData = image.pngData()
                } else {
                    // If no existing image object, create a new one
                    let newUserObject = User()
                    newUserObject.imageData = image.pngData()
                    realm.add(newUserObject)
                }
            }
        } catch {
            print("Error saving image to Realm: \(error.localizedDescription)")}
    }
    
    // Retrieve image from Realm
    func retrieveImageFromRealm() -> UIImage? {
        do {
            if let userObject = realm.objects(User.self).first, let imageData = userObject.imageData {
                return UIImage(data: imageData)
            }
        }
        return nil
    }
    
    // Display the Realm image to the view controller
    func loadSavedImage() {
        if let savedUser = realm.objects(User.self).first, let imageData = savedUser.imageData {
            userProfileImage.image = UIImage(data: imageData)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let searchedTrips = searchedTrips, !searchedTrips.isEmpty {
            return searchedTrips.count
        } else {
            return 0
        }
    }
    
    // ignore the warning
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RouteCell", for: indexPath) as! CellViewTemplate
            
            if let searchedTrip = searchedTrips?[indexPath.row], let trip = searchedTrip.trip, let emission = trip.emissions.first {
                let formattedEmissions = String(format: "%.3f", emission.value)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy"
                let formattedDate = dateFormatter.string(from: emission.date)
                
                cell.carbonEmissions.text = "\(formattedEmissions)"
                cell.dateVar.text = "\(formattedDate)"
            } else {
                // handle case where searchedTrip or emission is nil
                cell.carbonEmissions.text = "No emission data available"
                cell.dateVar.text = "No date available"
            }
            return cell
        }
    
}
