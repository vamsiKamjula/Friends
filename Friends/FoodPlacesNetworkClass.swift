//
//  FoodPlacesNetworkClass.swift
//  Friends
//
//  Created by vamsi krishna reddy kamjula on 9/5/17.
//  Copyright © 2017 applicationDevelopment. All rights reserved.
//

import Foundation

class FoodPlacesNetworkClass {

    var placesData = [[String: Any]]()
    var key: String?
    
    
    var name: String?
    var address: String?
    
    func dataCall(latitude: Double, longitude: Double, completionHandler: @escaping([[String: Any]]) -> Void) {
        
        self.fetchTheMovieTMDBAPI()
        
        let urlString = "https://developers.zomato.com/api/v2.1/search?lat=\(latitude)&lon=\(longitude)";
        let url = URL.init(string: urlString)
        
        if url != nil {
            let request = NSMutableURLRequest(url: url!)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue(key!, forHTTPHeaderField: "user_key")
            
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) -> Void in
                if error == nil {
                    let httpResponse = response as! HTTPURLResponse!
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        if httpResponse?.statusCode == 200 {
                            do {
                                guard let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: Any] else {
                                    return
                                }
                                guard let restaurants = json["restaurants"] as? [[String: Any]] else {
                                    return
                                }
                                for eachRestaurant in restaurants {
                                    if let restaurant = eachRestaurant["restaurant"] as? [String: Any] {
                                        if let name = restaurant["name"] as? String {
                                            self.name = name
                                        }
                                        
                                        if let location = restaurant["location"] as? [String: Any] {
                                            if let address = location["address"] as? String {
                                                self.address = address
                                            }
                                        }
                                        
                                        self.placesData.append(["Name": self.name!, "Address": self.address!])
                                    }
                                }
                                DispatchQueue.main.async {
                                    completionHandler(self.placesData)
                                }
                            } catch let error {
                                print(error)
                            }
                        }
                    }
                }
            })
            task.resume()
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
            if let key = plistData["ZomatoAPI"] as? String {
                self.key = key
            }
        } catch let plistError {
            print(plistError.localizedDescription)
        }
    }
}
