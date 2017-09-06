//
//  MoviesVC.swift
//  Friends
//
//  Created by vamsi krishna reddy kamjula on 9/3/17.
//  Copyright © 2017 applicationDevelopment. All rights reserved.
//

import UIKit
import FirebaseAuth
import CoreLocation

class MoviesVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var collectionViewForMoviePosters: UICollectionView!
    @IBOutlet weak var overview: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!

    let collectionViewIdentifier = "moviePosterCell"
    var key: String?
    var movieData = [[String: Any]]()
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.locationManager.delegate = self
        
        self.fetchTheMovieTMDBAPI()
        self.networkcallToParseTheData()
        
        overview.isHidden = true
        overviewLabel.isHidden = true
        
        self.navigationController?.navigationBar.backgroundColor = UIColor.blue
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedAlways {
            print("Location Accessed")
            locationManager.startUpdatingLocation()
        }
    }
    
    func networkcallToParseTheData() {
        let movieModelClass = MovieNetworkClass()
        movieModelClass.parsingTheMovieData(urlString: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(key!)&language=en-US&page=1") { (data) in
            self.movieData.append(contentsOf: data)
            self.collectionViewForMoviePosters.reloadData()
        }
    }
    
    func fetchTheMovieTMDBAPI() {
        let path = Bundle.main.path(forResource: "APIKeyInfo", ofType: "plist")
        guard let data = FileManager.default.contents(atPath: path!) else {
            return
        }
        var format = PropertyListSerialization.PropertyListFormat.xml
        do {
            let plistData = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: &format) as! [String:Any]
            if let key = plistData["TMDBAPIKey"] as? String {
                self.key = key
            }
        } catch let plistError {
            print(plistError.localizedDescription)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "moviePosterCell", for: indexPath)
        
        let imageView = cell.viewWithTag(1) as! UIImageView
        let url = URL.init(string: (movieData[indexPath.row]["WallPoster"] as? String)!)
        imageView.sd_setImage(with: url!, placeholderImage: #imageLiteral(resourceName: "Image"), options: [.continueInBackground, .progressiveDownload])
        
        let titleLabel = cell.viewWithTag(2) as! UILabel
        titleLabel.text = movieData[indexPath.row]["Title"] as? String
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.layer.borderWidth = 3.0
            cell.layer.borderColor = UIColor.black.cgColor
            overview.isHidden = false
            overviewLabel.isHidden = false
            
            overviewLabel.text = movieData[indexPath.row]["Overview"] as? String
            overviewLabel.numberOfLines = 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.layer.borderWidth = 0.0
            cell.layer.borderColor = UIColor.init(red: 148/255, green: 205/255, blue: 234/255, alpha: 1).cgColor
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        overviewLabel.isHidden = true
        overview.isHidden = true
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            self.presentingLogInScreen()
        } catch let signoutError {
            print(signoutError.localizedDescription)
        }
    }
    
    func presentingLogInScreen() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController: UIViewController = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.present(viewController, animated: true, completion: nil)
    }
}
