//
//  User.swift
//  MusicMind
//
//  Created by Angel Contreras on 4/3/17.
//  Copyright © 2017 MusicMind. All rights reserved.
//

import Foundation
import Firebase

// Create new user
// Init preexisting user
// Update user info

struct User {
    private let users = FIRDatabase.database().reference(withPath: "users")
    private let currentUser: FIRDatabaseReference?
    
    init(firebaseUserWithUuid uuid: String) {
        self.currentUser = users.child(uuid)
        self.uuid = uuid
        self.firstName = nil
        self.lastName = nil
        self.mobileNumber = nil
        self.birthday = nil
    }
    
    init(newUserWithFirstName firstName: String?, lastName: String?) {
        currentUser = users.childByAutoId()
        
        self.uuid = "testing1233"
        self.firstName = firstName
        self.lastName = lastName
        self.birthday = nil
        self.mobileNumber = nil
        
//        newUserRef.child("lastName").setValue(lastName)
    }
    
//    func addUserToUserList(_ user: User) {
//        var userAsDictionary: [String: Any] = [:]
//        
//        for (key, value) in user.dictionaryRepresentation {
//            if let value = value {
//                userAsDictionary[key] = value
//            }
//        }
//        usersRef.child(uuid).updateChildValues(userAsDictionary)
//    }
//    
    var uuid: String?
    var firstName: String? {
        didSet {
            if let uuid = uuid, let firstName = firstName, let currentUser = currentUser {
                currentUser.child("\(uuid)/firstName").setValue(firstName)
            }
        }
    }
    var lastName: String?
    var mobileNumber: String?
    var birthday: Date?
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyy-MM-dd"
    
}
