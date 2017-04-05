//
//  EmailPasswordViewController.swift
//  MusicMind
//
//  Created by Angel Contreras on 3/30/17.
//  Copyright © 2017 MusicMind. All rights reserved.
//

import UIKit
import FirebaseAuth

class EmailPasswordViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!
    
    var newUser = User()

    override func viewDidLoad() {
        super.viewDidLoad()
        print(newUser.dictionaryRepresentation)
    }


    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let email = emailTextField.text,
            let password = passwordTextField.text,
            let confirmedPassword = passwordConfirmationTextField.text,
            password == confirmedPassword else {
                let alertController = UIAlertController(title: "Error", message: "Please make sure all fields are filled and passwords match.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
                    self.passwordTextField.text = nil
                    self.passwordConfirmationTextField.text = nil
                })
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                return
            
        }
        
        userLoginCredentials.firebaseUserEmail = email
        userLoginCredentials.firebaseUserPassword = password
        
        FIRAuth.auth()?.createUser(withEmail: email, password: passwordTextField.text!, completion: { (user, error) in
            //TODO: handle error 17001 when the user already exists in firebase
                    
            self.newUser.firebaseUUID = user?.uid
        })
        
    }

}

