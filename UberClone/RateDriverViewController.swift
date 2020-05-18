//
//  RateDriverViewController.swift
//  UberClone
//
//  Created by Eric Ngo on 5/18/20.
//  Copyright © 2020 Dinky. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class RateDriverViewController: UIViewController {

    var driverEmail = ""
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var ratingInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        submitButton.setTitle("Rate \(driverEmail)", for: .normal)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onSubmitRating(_ sender: Any) {
        Database.database().reference().child("UserRatings").queryOrdered(byChild: "email").queryEqual(toValue: driverEmail).observeSingleEvent(of:.value, with: {(snapshot) in
            if let userRatings = snapshot.value as? [String: AnyObject] {
                if let numRatings = userRatings["numRatings"] as? Double {
                    if let rating = userRatings["rating"] as? Double {
                        if let ratingInput = self.ratingInput.text {
                            let ratingInputDouble = Double(ratingInput)
                            if let unwrappedRatingInputDouble = ratingInputDouble {
                                let newNumRatings = numRatings + 1
                                let newRating = rating + unwrappedRatingInputDouble
                                // update DB Value
                                snapshot.ref.updateChildValues(["numRatings": newNumRatings,"rating": newRating])
                            }
                        }
                    }
                }
            }
        })
    }
}
