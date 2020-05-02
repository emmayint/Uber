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
    var driverLocation = CLLocationCoordinate2D()
    var driverOnTheWay = false
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
                if let rideRequestDictionary = snapshot.value as? [String: AnyObject] {
                    if let driverLat = rideRequestDictionary["driverLat"] as? Double {
                        if let driverLon = rideRequestDictionary["driverLon"] as? Double {
                            self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                            self.driverOnTheWay = true
                            self.displayDriverAndRider()
                            if let email = Auth.auth().currentUser?.email {
                                Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childChanged, with: {(snapshot) in
                                    
                                    if let rideRequestDictionary = snapshot.value as? [String: AnyObject] {
                                        if let driverLat = rideRequestDictionary["driverLat"] as? Double {
                                            if let driverLon = rideRequestDictionary["driverLon"] as? Double {
                                                self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                                                self.driverOnTheWay = true
                                                self.displayDriverAndRider()
                                            }
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            })
        }
    }
    
    func displayDriverAndRider() {
        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
        let riderCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000 // convert to kilometer
        let roundedDistance = round(distance * 100) / 100
        callAnUberButton.setTitle("Your driver is \(roundedDistance) away", for: .normal)
        
        map.removeAnnotations(map.annotations)
        
        let latDelta = abs(driverLocation.latitude - userLocation.latitude) * 2 + 0.005
        let lonDelta = abs(driverLocation.longitude - userLocation.longitude) * 2 + 0.005
        let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(
            latitudeDelta: latDelta, longitudeDelta: lonDelta
        ))
        map.setRegion(region, animated: true)
        let riderAnno = MKPointAnnotation()
        riderAnno.coordinate = userLocation
        riderAnno.title = "Your location"
        map.addAnnotation(riderAnno)
        
        let driverAnno = MKPointAnnotation()
        driverAnno.coordinate = driverLocation
        driverAnno.title = "Your driver"
        map.addAnnotation(driverAnno)
    }
    // called when new update about location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // get user's current location
        if let coord = manager.location?.coordinate {
            // Get center of where user should be
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            // update user location
            userLocation = center
            
            if uberHasBeenCalled {
                displayDriverAndRider()
                
            } else {
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
        if !driverOnTheWay {
            if let email = Auth.auth().currentUser?.email {
                
                if uberHasBeenCalled {
                    showCallUber()
                    Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: {(snapshot) in
                        
                        snapshot.ref.removeValue()
                        Database.database().reference().child("RideRequests").removeAllObservers()
                    })
                } else {
                    let rideRequestDictionary: [String:Any] = ["email":email,"lat":userLocation.latitude,"lon":userLocation.longitude]
                    Database.database().reference().child("RideRequests").childByAutoId().setValue(rideRequestDictionary)
                    
                    showCancelRide()
                    
                }
            }
        }
    }
    @IBAction func logoutTapped(_ sender: Any) {
        // logout from firebase
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
