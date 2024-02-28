//
//  NewUserViewModel.swift
//  developing_v2
//
//  Created by Sabrina Boc on 27/02/2024.
//

import UIKit

class NewUserViewModel {
    private var userValues: UserModel?
        
    let id: Int?
    let email: String?
    let firstName: String?
    let lastName: String?
    let password: String?
    let photo: UIImage?
    
    init(userValues: UserModel?) {
        self.userValues = userValues
            
        self.id = userValues?.id
        self.email = userValues?.email
        self.firstName = userValues?.firstName
        self.lastName = userValues?.lastName
        self.password = userValues?.password
        self.photo = UIImage(data: userValues!.photo)
    }
}
