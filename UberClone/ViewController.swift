//
//  ViewController.swift
//  UberClone
//
//  Created by Eric Ngo on 4/30/20.
//  Copyright © 2020 Dinky. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import GoogleSignIn

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var riderLabel: UILabel!
    @IBOutlet weak var driverLabel: UILabel!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var riderDriverSwitch: UISwitch!
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    var signUpMode = true
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
    }

    @IBAction func topTapped(_ sender: Any) {
        if emailTextField.text == "" || passwordTextField.text == "" {
            displayAlert(title: "Missing information", message: "You must provide both a email and password.")
        } else {
            if let email = emailTextField.text {
                if let password = passwordTextField.text {
                    if signUpMode {
                        // For signup
                        guard let imageSelected = profileImageView.image as? UIImage else{
                            print("no image selected")
                            return
                        }
                        guard let imageData = imageSelected.jpegData(compressionQuality: 0.4) else{
                            return
                        }
                        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                            // ...
                            if error != nil {
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                            } else {
                                if let authData = authResult{
                                    print(authData.email)
                                    
                                    // upload profile image to storage
                                    var dict: Dictionary<String, Any> = [
                                        "email":authData.email,
                                        "profileImageUrl":""
                                    ]
                                    let storageRef = Storage.storage().reference(forURL: "gs://uber-clone-8d8e9.appspot.com")
                                    let storageProfileRef = storageRef.child("profile").child(authData.email!)
                                    let metadata = StorageMetadata()
                                    metadata.contentType = "image/jpg"
                                    storageProfileRef.putData(imageData, metadata: metadata, completion: {(StorageMetadata, error) in
                                        if error != nil{
                                            print(error?.localizedDescription)
                                        }
                                        
                                        storageProfileRef.downloadURL(completion: {(url, error) in
                                            if let metaImageUrl = url?.absoluteString{
                                                dict["profileImageUrl"] = metaImageUrl
                                                print("created image in storage. url:", metaImageUrl)
                                                
                                                // update users db with profile image url
//                                                Database.database().reference().child("users").child(authData.email!).updateChildValues(dict, withCompletionBlock: {
//                                                    (error, ref) in
//                                                    if error == nil{
//                                                        print("profile added to db")
//                                                    }
//                                                })
                                            }
                                            if self.riderDriverSwitch.isOn {
                                                // DRIVER
                                                let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                                req?.displayName = "Driver"
                                                req?.commitChanges(completion: nil)
                                                self.performSegue(withIdentifier: "driverSegue", sender: nil)
                                            } else {
                                                // RIDER
                                                let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                                req?.displayName = "Rider"
                                                req?.commitChanges(completion: nil)
                                                self.performSegue(withIdentifier: "riderSegue", sender: nil)
                                            }
                                        })
                                    })
                                    // add User to ratings table
                                    let rideRequestDictionary: [String:Any] = ["email":authData.email,"rating":0.0, "numRatings": 0]
                                    Database.database().reference().child("UserRatings").childByAutoId().setValue(rideRequestDictionary)
                                }
                                
//                                if self.riderDriverSwitch.isOn {
//                                    // DRIVER
//                                    let req = Auth.auth().currentUser?.createProfileChangeRequest()
//                                    req?.displayName = "Driver"
//                                    req?.commitChanges(completion: nil)
//                                    self.performSegue(withIdentifier: "driverSegue", sender: nil)
//                                } else {
//                                    // RIDER
//                                    let req = Auth.auth().currentUser?.createProfileChangeRequest()
//                                    req?.displayName = "Rider"
//                                    req?.commitChanges(completion: nil)
//                                    self.performSegue(withIdentifier: "riderSegue", sender: nil)
//                                }
                                
                            }
                        }
                    } else {
                        // For login
                        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                            guard let strongSelf = self else { return }
                            // ...
                            if error != nil {
                                strongSelf.displayAlert(title: "Error", message: error!.localizedDescription)
                            } else {
                                print(authResult!.displayName)
                                if authResult?.displayName == "Driver" {
                                    // DRIVER
                                    strongSelf.performSegue(withIdentifier: "driverSegue", sender: nil)
                                } else {
                                    // RIDER
                                    strongSelf.performSegue(withIdentifier: "riderSegue", sender: nil)
                                }
                                strongSelf.performSegue(withIdentifier: "riderSegue", sender: nil)
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
      // ...
      if let error = error {
        print(error.localizedDescription)
        return
      }

      guard let authentication = user.authentication else { return }
      let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                        accessToken: authentication.accessToken)
    
      Auth.auth().signIn(with: credential) { (authResult, error) in
        if let error = error {
          return
        }
        // User is signed in
        // ...
      }
    }

    
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func bottomTapped(_ sender: Any) {
        if signUpMode {
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
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBAction func updateImageTapped(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            profileImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
//    @IBAction func updateTapped(_ sender: Any) {
        
//    }
}

