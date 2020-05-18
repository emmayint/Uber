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
import FirebaseStorage
import Kingfisher

class RiderViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var callAnUberButton: UIButton!
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var driverImageView: UIImageView!
    @IBOutlet weak var driverEmailLabel: UILabel!
    @IBOutlet weak var riderEmailLabel: UILabel!
    
    // get uer location
    var locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    var uberHasBeenCalled = false
    var driverLocation = CLLocationCoordinate2D()
    var driverEmail = ""
    var driverOnTheWay = false
    func showCallUber() {
        // reset vals
        uberHasBeenCalled = false
        driverOnTheWay = false
        driverEmail = ""
        driverLocation = CLLocationCoordinate2D()
        callAnUberButton.setTitle("Call an Uber", for: .normal)
    }
    
    func showCancelRide() {
        uberHasBeenCalled = true
        callAnUberButton.setTitle("Cancel Uber", for: .normal)
    }
    
//    func downloadImage(from url: URL) {
//        print("Download Started")
//        getData(from: url) { data, response, error in
//            guard let data = data, error == nil else { return }
//            print(response?.suggestedFilename ?? url.lastPathComponent)
//            print("Download Finished")
//            DispatchQueue.main.async() { [weak self] in
//                self?.profileImage.image = UIImage(data: data)
//            }
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // ask user to get location
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        if let email = Auth.auth().currentUser?.email {
            
            //get user rider profile image
            print("current rider email", email)
            riderEmailLabel.text = "Hi " + email
            let storageRef = Storage.storage().reference(forURL: "gs://uber-clone-8d8e9.appspot.com")
            let storageProfileRef = storageRef.child("profile").child(email)
            storageProfileRef.downloadURL(completion: {
                (url, error) in
                if let metaImageUrl = url?.absoluteString{
//                  dict["profileImageUrl"] = metaImageUrl
                    print("rider view imgurl:", metaImageUrl)
                    
                    let url = URL(string: metaImageUrl)
                    let processor = RoundCornerImageProcessor(cornerRadius: 100000)
                    self.profileImage.kf.indicatorType = .activity
                    self.profileImage.kf.setImage(
                        with: url,
                        placeholder: UIImage(named: "placeholderImage"),
                        options: [
                            .processor(processor),
                            .scaleFactor(UIScreen.main.scale),
                            .transition(.fade(1)),
                            .cacheOriginalImage
                        ])
                    {
                        result in
                        switch result {
                        case .success(let value):
                            print("Task done for: \(value.source.url?.absoluteString ?? "")")
                        case .failure(let error):
                            print("Job failed: \(error.localizedDescription)")
                        }
                    }
                    
                }
            })
            
            // if user already in DB (already request ride), show cancel ride state
            Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .childAdded, with: {(snapshot) in
                self.showCancelRide()
                if let rideRequestDictionary = snapshot.value as? [String: AnyObject] {
                    if let driverLat = rideRequestDictionary["driverLat"] as? Double {
                        if let driverLon = rideRequestDictionary["driverLon"] as? Double {
                            self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                            self.driverOnTheWay = true
                            self.displayDriverAndRider()
                        }
                    }
                    
                    //get driver profile image
                    if let driverEmail = rideRequestDictionary["driverEmail"] as? String{
                        self.driverEmail = driverEmail
                        print("driverEmail in request:", driverEmail)
                        self.driverEmailLabel.text = "your driver: " + driverEmail
                        print("show driver email label")
                        let storageRef = Storage.storage().reference(forURL: "gs://uber-clone-8d8e9.appspot.com")
                        let storageProfileRef = storageRef.child("profile").child(driverEmail)
                        storageProfileRef.downloadURL(completion: {
                            (url, error) in
                            if let metaImageUrl = url?.absoluteString{
                                print("rider view imgurl:", metaImageUrl)
                                
                                let url = URL(string: metaImageUrl)
                                let processor = RoundCornerImageProcessor(cornerRadius: 100000)
                                self.driverImageView.kf.indicatorType = .activity
                                self.driverImageView.kf.setImage(
                                    with: url,
                                    placeholder: UIImage(named: "placeholderImage"),
                                    options: [
                                        .processor(processor),
                                        .scaleFactor(UIScreen.main.scale),
                                        .transition(.fade(1)),
                                        .cacheOriginalImage
                                    ])
                                {
                                    result in
                                    switch result {
                                    case .success(let value):
                                        print("Task done for: \(value.source.url?.absoluteString ?? "")")
                                    case .failure(let error):
                                        print("Job failed: \(error.localizedDescription)")
                                    }
                                }
                
                        })
                    }
                }
            })
            
            // if user already in DB (already request ride), show cancel ride state
            Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .childChanged, with: {(snapshot) in
                print("Child has been updated...")
                if let rideRequestDictionary = snapshot.value as? [String: AnyObject] {
                    if let driverLat = rideRequestDictionary["driverLat"] as? Double {
                        if let driverLon = rideRequestDictionary["driverLon"] as? Double {
                            self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                            self.driverOnTheWay = true
                            self.displayDriverAndRider()
                            if let driverEmail = rideRequestDictionary["driverEmail"] as? String {
                                self.driverEmail = driverEmail
                            }
                        }
                    }
                }
            })
            
            Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .childRemoved, with: {(snapshot) in
                //
                print("Ride finished")
                if let rideRequestDictionary = snapshot.value as? [String: AnyObject] {
                    if let driverEmail = rideRequestDictionary["driverEmail"] as? String {
                        self.showRatingInput(driverEmail: driverEmail)
                    }
                }
                self.showCallUber()
            })


        }
    }
    
    func showRatingInput(driverEmail: String) {
        print(driverEmail)
        // prepare segue
        performSegue(withIdentifier: "rateDriverSegue", sender: driverEmail)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // pass information
        if let rateDriverVC = segue.destination as? RateDriverViewController {
            if let driverEmail = sender as? String {
                rateDriverVC.driverEmail = driverEmail
            }
        }
    }
    
    func displayDriverAndRider() {
        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
        let riderCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000 // convert to kilometer
        let roundedDistance = round(distance * 100) / 100
        callAnUberButton.setTitle("Your driver is \(roundedDistance)kms away", for: .normal)
        
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
            
            if driverOnTheWay {
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
                    Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.value, with: {(snapshot) in
                        
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
