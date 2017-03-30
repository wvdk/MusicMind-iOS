//
//  NumberEntryViewController.swift
//  MusicMind
//
//  Created by Wesley Van der Klomp on 3/29/17.
//  Copyright © 2017 MusicMind. All rights reserved.
//

import UIKit
import SinchVerification

class NumberEntryViewController: UIViewController {
    
    var verification: Verification!
    var sinchApplicationKey = "a7047f26-664e-47e5-abf8-02013452c9d4"
    
    @IBOutlet weak var numberEntryTextField: UITextField!
    @IBOutlet weak var getCodeButton: UIButton!
    
    // MARK: - IBActions
    
    @IBAction func attemptValidation(_ sender: Any) {
        verification =
            SMSVerification(sinchApplicationKey,
                            phoneNumber: numberEntryTextField.text!)
        verification.initiate { (result, error) in
            if result.success {
                print("success")
                self.performSegue(withIdentifier: "enterPin", sender: sender)
            } else {
                print(error.debugDescription)
            }

        }
    }
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        numberEntryTextField.becomeFirstResponder()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "enterPin" {
            let vc = segue.destination as! ValidationCodeEntryViewController
            
            vc.verification = self.verification
        }
    }
}
