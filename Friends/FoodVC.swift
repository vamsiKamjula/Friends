//
//  FoodVC.swift
//  Friends
//
//  Created by vamsi krishna reddy kamjula on 9/4/17.
//  Copyright © 2017 applicationDevelopment. All rights reserved.
//

import UIKit
import FirebaseAuth
import CoreLocation

class FoodVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate {

    @IBOutlet weak var placesCollectionView: UICollectionView!
    var places = [[String: Any]]()
    let locationManager = CLLocationManager()
    
    var latitude: Double?
    var longitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        locationManager.desiredAccuracy = 10.0
        
        self.gettingUserLocation()
    }
    
    func gettingUserLocation() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways:
                locationManager.startUpdatingLocation()
            default:
                locationManager.requestAlwaysAuthorization()
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.latitude = Double(locations.last?.coordinate.latitude ?? 40.759211000000001)
        self.longitude = Double(locations.last?.coordinate.longitude ?? -73.984638000000004)
        locationManager.stopUpdatingLocation()
        self.gettingPlacesData()
    }
    
    func gettingPlacesData() {
        let foodPlacesCall = FoodPlacesNetworkClass()
        foodPlacesCall.dataCall(latitude: latitude!, longitude: longitude!) { (data) in
            DispatchQueue.main.async {
                self.places.append(contentsOf: data)
                self.placesCollectionView.reloadData()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            self.presentingLogInScreen()
        }catch let signoutError {
            print(signoutError.localizedDescription)
        }
    }
    
    func presentingLogInScreen() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController: UIViewController = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func segementSelectedTitle(_ sender: CustomSegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            placesCollectionView.isHidden = false
        case 1:
            placesCollectionView.isHidden = true
        default:
            print("Select")
        }
    }
    
    let reuseIdentifier = "foodPlacesCell"
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return places.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        let nameLabel = cell.viewWithTag(1) as! UILabel
        nameLabel.text = places[indexPath.row]["Name"] as? String
        
        let addressLabel = cell.viewWithTag(2) as! UILabel
        addressLabel.text = places[indexPath.row]["Address"] as? String
        
        return cell
    }
    
}
