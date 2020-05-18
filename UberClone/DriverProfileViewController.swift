//
//  DriverProfileViewController.swift
//  UberClone
//
//  Created by Eric Ngo on 5/17/20.
//  Copyright © 2020 Dinky. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import Kingfisher

class DriverProfileViewController: UIViewController {

    @IBOutlet weak var greetingLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var ridesButton: UIButton!
    
    @IBOutlet weak var completeRideButton: UIButton!
    
    @IBOutlet weak var navigateRideButton: UIButton!
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    var currentRideRequestLocation: [String: AnyObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // initially, no ride state
        noRideState()
        // update state accordingly
        driverUIUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        driverUIUpdate()
    }
    
    func noRideState() {
        completeRideButton.isHidden = true
        navigateRideButton.isHidden = true
        ridesButton.isHidden = false
        statusLabel.text = "Ready to start your next ride?"
    }
    
    func hasRideState() {
        completeRideButton.isHidden = false
        navigateRideButton.isHidden = false
        ridesButton.isHidden = true
        statusLabel.text = "You are currently in a ride!"
    }
    

    /*
    // MARK: - Navigation
    */
    func driverUIUpdate() {
        
        if let driverEmail = Auth.auth().currentUser?.email {
            // update greeting text
            greetingLabel.text = "Hi \(driverEmail)!"
            // if user is currently in a ride, hide ride request button and update text
            
            Database.database().reference().child("RideRequests").queryOrdered(byChild: "driverEmail").queryEqual(toValue: driverEmail).observe(.childAdded, with: {(snapshot) in
                
                // unsubscribe from observable
                Database.database().reference().child("RideRequests").removeAllObservers()
                
                if let rideRequestDictionary = snapshot.value as? [String: AnyObject] {
                    self.currentRideRequestLocation = rideRequestDictionary
                    self.hasRideState()
                }
            })
        }
        
        
    }

    @IBAction func logoutTapped(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func completeRideTapped(_ sender: Any) {
        if let driverEmail = Auth.auth().currentUser?.email {
            // remove ride from ride requests
            Database.database().reference().child("RideRequests").queryOrdered(byChild: "driverEmail").queryEqual(toValue: driverEmail).observe(.childAdded, with: {(snapshot) in
                
                snapshot.ref.removeValue()
                Database.database().reference().child("RideRequests").removeAllObservers()
                self.noRideState()
            })
        }
    }
    @IBAction func navigateRideTapped(_ sender: Any) {
        if let rideRequestDictionary = currentRideRequestLocation {
            if let email = rideRequestDictionary["email"] as? String {
                if let lat = rideRequestDictionary["lat"] as? Double {
                    if let lon = rideRequestDictionary["lon"] as? Double {
                        let requestLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        // give directions
                        let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
                        CLGeocoder().reverseGeocodeLocation(requestCLLocation) {(placemarks, error) in
                            if let placemarks = placemarks {
                                if placemarks.count > 0 {
                                    let placemark = MKPlacemark(placemark: placemarks[0])
                                    let mapItem = MKMapItem(placemark: placemark)
                                    // rider's email
                                    mapItem.name = email
                                    
                                    // launch items
                                    let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                                    mapItem.openInMaps(launchOptions: options)
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
}
