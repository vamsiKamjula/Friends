//
//  MovieNetworkClass.swift
//  Friends
//
//  Created by vamsi krishna reddy kamjula on 9/3/17.
//  Copyright © 2017 applicationDevelopment. All rights reserved.
//

import Foundation

class MovieNetworkClass {

    var movieData = [[String: Any]]()
    
    var title: String?
    var backdropPoster: String?
    var overview: String?

    func parsingTheMovieData(urlString: String, completionHandler: @escaping([[String:Any]]) -> Void) {
        let url = URL.init(string: urlString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if let dataError = error {
                print(dataError.localizedDescription)
                return
            }
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] else {
                        return
                    }
                    
                    guard let results = json["results"] as? [[String: Any]] else {
                        return
                    }
                    
                    for eachArray in results {
                        if let title = eachArray["title"] as? String {
                            self.title = title
                        }
                        if let backdropPoster = eachArray["backdrop_path"] as? String {
                            let baseUrl = "http://image.tmdb.org/t/p/original/"
                            self.backdropPoster = baseUrl+backdropPoster
                        }
                        if let overview = eachArray["overview"] as? String {
                            self.overview = overview
                        }
                        self.movieData.append(["Title": self.title!, "WallPoster": self.backdropPoster!, "Overview": self.overview!])
                    }
                    DispatchQueue.main.async {
                        completionHandler(self.movieData)
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
}
