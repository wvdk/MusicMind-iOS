//
//  User.swift
//  MusicMind
//
//  Created by Angel Contreras on 4/3/17.
//  Copyright © 2017 MusicMind. All rights reserved.
//

import Foundation
import Firebase

class User {
    var userRef: FIRDatabaseReference? {
        didSet {
            // Create an observer for entire user listing in firebase that will update the values of this user instance when updates are made to firebase
            userRef?.observe(.value, with: { (snapshot) in
                if let user = snapshot.value as? [String: Any?] {
                    print(user.debugDescription)
                    
                    if let firstName = user["firstName"] as? String {
                        self.firstName = firstName
                    }
                    
                }
                
            })
        }
    }
    var firebaseAuthUser: FIRUser?
    let id: String?
    var firstName: String? {
        didSet {
            if let firstName = firstName, let userRef = userRef {
                userRef.setValue(["firstName": firstName])
            }
        }
    }
    var lastName: String? {
        didSet {
            if let lastName = lastName, let userRef = userRef {
                userRef.setValue(["lastName": lastName])
            }
        }
    }
    var mobileNumber: String? {
        didSet {
            if let number = mobileNumber, let userRef = userRef {
                userRef.setValue(["mobileNumber": number])
            }
        }
    }
    var birthday: Date? {
        didSet {
            if let birthday = birthday, let userRef = userRef {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                let birthdayString = formatter.string(from: birthday)
                
                userRef.setValue(["birthday": birthdayString])
            }
        }
    }
    private(set) var email: String?
    
    init() {
        userRef = nil
        id = nil
        firstName = nil
        lastName = nil
        mobileNumber = nil
        birthday = nil
        email = nil
    }
    
    func pushNewUserToFirebaseDatabase(assosiatedWithAuthUser authUser: FIRUser) {
        userRef = FIRDatabase.database().reference().child("users/\(authUser.uid)")
        
        if let userRef = userRef,
            let firstName = firstName,
            let lastName = lastName,
            let mobileNumber = mobileNumber,
            let birthday = birthday {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            let birthdayString = formatter.string(from: birthday)
            
            userRef.setValue(["firstName": firstName,
                              "lastName": lastName,
                              "mobileNumber": mobileNumber,
                              "birthday": birthdayString],
                             withCompletionBlock: { (error, ref) in
                                // completion code
            })
            
            
        }
        
    }
    
    init(withAuthUser authUser: FIRUser) {
        userRef = FIRDatabase.database().reference().child("users/\(authUser.uid)")
        
        // TODO: fetch single and set all values for self from the snapshot
        
        id = authUser.uid
        firstName = nil
        lastName = nil
        mobileNumber = nil
        birthday = nil
        email = nil
    }


}
