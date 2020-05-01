//
//  ViewController.swift
//  Uber
//
//  Created by Emma Macbook Pro on 5/1/20.
//  Copyright © 2020 CSC690. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet weak var riderLabel: UILabel!
    
    @IBOutlet weak var driverLabel: UILabel!
    
    @IBOutlet weak var emailTextfield: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var riderDriverSwitch: UISwitch!
    
    @IBOutlet weak var topButton: UIButton!
    
    @IBOutlet weak var bottomButton: UIButton!
    
    
    
    var signUpMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func topTapped(_ sender: Any) {
        if emailTextfield.text=="" || passwordTextField.text==""{
            displayAlert(title: "Missing Information", message: "email and password required")
        } else {
            if let email = emailTextfield.text{
                if let password = passwordTextField.text{
                    if signUpMode{
                        // TODO: sign up
                        
                        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                            if error != nil{
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                            }else{
                                print("--Sign Up Success!")
                            }
                        }
                    } else {
                        // TODO: login
                        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                            if error != nil{
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                            }else{
                                print("--Log In Success!")
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    func displayAlert(title:String, message:String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func bottomTapped(_ sender: Any) {
        if signUpMode{
            topButton.setTitle("Log In", for: .normal)
            bottomButton.setTitle("Switch to Sign Up", for: .normal)
            riderLabel.isHidden = true
            driverLabel.isHidden = true
            riderDriverSwitch.isHidden = true
            signUpMode = false
        } else {
            topButton.setTitle("Sign Up", for: .normal)
            bottomButton.setTitle("Switch to Log In", for: .normal)
            riderLabel.isHidden = false
            driverLabel.isHidden = false
            riderDriverSwitch.isHidden = false
            signUpMode = true
        }
    }
}

