//
//  UserDataViewController.swift
//  developing_v2
//
//  Created by Sabrina Boc on 22/02/2024.
//

import UIKit

class UserDataViewController: UIViewController {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
        
    var viewModel: NewUserViewModel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createTable()
        setUpViews()
        emailTextField.becomeFirstResponder()
    }
        
    // MARK: - Connect to database and create table.
    private func createTable() {
        let database = SQLiteDatabase.sharedInstance
        database.createTable()
    }
        
    // MARK: - Setup the views with the values of the selected contact
    private func setUpViews() {
        if let viewModel = viewModel {
            emailTextField.text = viewModel.email
            firstNameTextField.text = viewModel.firstName
            lastNameTextField.text = viewModel.lastName
            passwordTextField.text = viewModel.password
            photoImageView.image = viewModel.photo
        }
    }
    
    // MARK: - Save new contact or update an existing contact
    @IBAction func saveButton(_ sender: Any) {
        let id: Int = viewModel == nil ? 0 : viewModel.id!
        let email = emailTextField.text ?? ""
        let firstName = firstNameTextField.text ?? ""
        let lastName = lastNameTextField.text ?? ""
        let password = lastNameTextField.text ?? ""
        let uiImage = photoImageView.image ?? #imageLiteral(resourceName: "defualtContactIPhoto")
        guard let photo = uiImage.pngData() else {return}
        
        let userValues = UserModel(id: id, email: email,firstName: firstName, lastName: lastName, password: password, photo: photo)
            
        // If viewModel equal to nil a new contact will be created, otherwise an existing contact will be updated.
        if viewModel == nil {
            // Contact created
            createNewUser(userValues)
        }
    }
        
    // MARK: - Create new contact
    private func createNewUser(_ userValues: UserModel) {
        let userAddedToTable = SQLiteCommands.insertRow(userValues)
        
        // Phone number is unique to each contact so we check if it already exists
        if userAddedToTable == true {
            dismiss(animated: true, completion: nil)
        } else {
            print("Error: Email already registered")
        }
    }
        
    // MARK: - Cancel button
    @IBAction func cancelButton(_ sender: Any) {
        let addButtonClicked = presentingViewController is UINavigationController
        // If the user clicked add button on the previous screen
        if addButtonClicked {
            // Dismisses back to the previous screen with animation
            dismiss(animated: true, completion: nil)
        }
        // If the user clicked on a cell on the previous screen
        else if let cellClicked = navigationController {
            cellClicked.popViewController(animated: true)
        } else {
            print("The ContactScreenTableViewController is not inside a navigation controller")
        }
    }
}

extension UserDataViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - Image tap gesture
    @IBAction func addImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        // let the user pick media from his photo library.
        let imagePickerController = UIImagePickerController()
        
        // Allows to picked photos.
        imagePickerController.sourceType = .photoLibrary
        
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        photoImageView.image = selectedImage
        
        dismiss(animated: true, completion: nil)
    }
}
