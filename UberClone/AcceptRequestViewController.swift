//
//  AcceptRequestViewController.swift
//  UberClone
//
//  Created by Eric Ngo on 5/1/20.
//  Copyright © 2020 Dinky. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseStorage
import Kingfisher

class AcceptRequestViewController: UIViewController {
    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var riderImageView: UIImageView!
    @IBOutlet weak var riderLabel: UILabel!
    
    var requestLocation = CLLocationCoordinate2D()
    var driverLocation = CLLocationCoordinate2D()
    var requestEmail = ""
    var driverEmail = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: false)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = requestLocation
        annotation.title = requestEmail
        map.addAnnotation(annotation)
        riderLabel.text = self.requestEmail
        //get profile image
        print("requestEmail:", self.requestEmail)
        let storageRef = Storage.storage().reference(forURL: "gs://uber-clone-8d8e9.appspot.com")
        let storageProfileRef = storageRef.child("profile").child(self.requestEmail)
        storageProfileRef.downloadURL(completion: {
            (url, error) in
            if let metaImageUrl = url?.absoluteString{
                print("rider view imgurl:", metaImageUrl)
                
                let url = URL(string: metaImageUrl)
                let processor = RoundCornerImageProcessor(cornerRadius: 100000)
                self.riderImageView.kf.indicatorType = .activity
                self.riderImageView.kf.setImage(
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
        
    }
    
    @IBAction func acceptTapped(_ sender: Any) {
        // Update ride request
        Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: requestEmail).observe(.childAdded) {(snapshot) in
            snapshot.ref.updateChildValues(["driverLat": self.driverLocation.latitude, "driverLon": self.driverLocation.longitude, "driverEmail": self.driverEmail])
            Database.database().reference().child("RideRequests").removeAllObservers()
        }
        // give directions
        let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) {(placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count > 0 {
                    let placemark = MKPlacemark(placemark: placemarks[0])
                    let mapItem = MKMapItem(placemark: placemark)
                    mapItem.name = self.requestEmail
                    
                    // launch items
                    let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMaps(launchOptions: options)
                }
            }
        }
        performSegue(withIdentifier: "backToHomeSegue", sender: nil)
    }
    
}
