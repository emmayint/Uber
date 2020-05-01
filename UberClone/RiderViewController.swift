//
//  RiderViewController.swift
//  UberClone
//
//  Created by Eric Ngo on 5/1/20.
//  Copyright © 2020 Dinky. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth

class RiderViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var callAnUberButton: UIButton!
    @IBOutlet weak var map: MKMapView!
    
    // get uer location
    var locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    var uberHasBeenCalled = false
    
    func showCallUber() {
        uberHasBeenCalled = false
        callAnUberButton.setTitle("Call an Uber", for: .normal)
    }
    
    func showCancelRide() {
        uberHasBeenCalled = true
        callAnUberButton.setTitle("Cancel Uber", for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // ask user to get location
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        if let email = Auth.auth().currentUser?.email {
            // if user already in DB (already request ride), show cancel ride state
            Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: {(snapshot) in
                self.showCancelRide()
                Database.database().reference().child("RideRequests").removeAllObservers()
            })
        }
    }
    // called when new update about location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // get user's current location
        if let coord = manager.location?.coordinate {
            // Get center of where user should be
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            // update user location
            userLocation = center
            let region = MKCoordinateRegion(center: center, span:
                MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            map.setRegion(region, animated: true)
            // create annotation (dot on our map)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = center
            annotation.title = "Your location"
            map.removeAnnotations(map.annotations)
            map.addAnnotation(annotation)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func callUberTapped(_ sender: Any) {
        if let email = Auth.auth().currentUser?.email {

            if uberHasBeenCalled {
                showCallUber()
                Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: {(snapshot) in
                    
                    snapshot.ref.removeValue()
                    Database.database().reference().child("RideRequests").removeAllObservers()
                })
            } else {
                    let rideRequestDictionary: [String:Any] = ["email":email,"lat":userLocation.longitude,"lon":userLocation.latitude]
                    Database.database().reference().child("RideRequests").childByAutoId().setValue(rideRequestDictionary)
                    
                    showCancelRide()
                
            }
        }
    }
    @IBAction func logoutTapped(_ sender: Any) {
        // logout from firebase
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
