//
//  ViewController.swift
//  MyApp
//
//  Created by Vladislav Stolyarov on 26.02.2023.
//

import UIKit
import SDWebImage

class ViewController: UIViewController {

    @IBOutlet private weak var MainView: UIView!
    
    @IBOutlet private weak var shareButton: UIButton!
    
    @IBOutlet private weak var usernameLabel: UILabel!
    
    @IBOutlet private weak var domainLabel: UILabel!
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private weak var timePassedLabel: UILabel!
    
    @IBOutlet private weak var ratingLabel: UILabel!
    
    @IBOutlet private weak var commentsCountLabel: UILabel!
    
    @IBOutlet private weak var bookmarkButton: UIButton!
    
    @IBOutlet private weak var redditImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        struct RedditAPIRequest {
            let baseURL = "https://www.reddit.com"
            let path: String
            var subreddit: String?
            var limit: Int?
            var after: String?
            
            var url: URL? {
                var urlComponents = URLComponents(string: baseURL)
                urlComponents?.path = path
                var queryItems = [URLQueryItem]()
                if let subreddit = subreddit {
                    queryItems.append(URLQueryItem(name: "subreddit", value: subreddit))
                }
                if let limit = limit {
                    queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
                }
                if let after = after {
                    queryItems.append(URLQueryItem(name: "after", value: after))
                }
                urlComponents?.queryItems = queryItems
                return urlComponents?.url
            }
        }

        let request = RedditAPIRequest(path: "/r/ios/top.json", subreddit: "ios", limit: 1)
        let session = URLSession.shared
        let task = session.dataTask(with: request.url!) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response")
                return
            }
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let redditAPIResponse = try decoder.decode(RedditAPIResponse.self, from: data)
                    for child in redditAPIResponse.data.children {
                        DispatchQueue.main.async {
                            self.titleLabel.text = child.data.title
                            self.commentsCountLabel.text = String(child.data.numComments)
                            self.ratingLabel.text = String(child.data.ups+child.data.downs)
                            self.usernameLabel.text = child.data.author
                            self.domainLabel.text = child.data.domain
                            let timeElapsed = Int(Date().timeIntervalSince1970 - child.data.createdUtc)
                            let timeString: String
                            if timeElapsed < 3600 {
                                timeString = "\(timeElapsed / 60)m"
                            } else if timeElapsed < 86400 {
                                timeString = "\(timeElapsed / 3600)h"
                            } else {
                                timeString = "\(timeElapsed / 86400)d"
                            }
                            self.timePassedLabel.text = timeString
                            
                            self.bookmarkButton.setImage(child.data.saved ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark"), for: .normal)
                            
                            self.redditImage.sd_setImage(with: child.data.url) 



                        }
                            }
                } catch {
                    print("Error decoding JSON: \(error.localizedDescription)")
                }
            }
        }
        task.resume()

        

        
    }
    
    struct RedditAPIResponse: Codable {
        let kind: String
        let data: RedditData
    }

    struct RedditData: Codable {
        let children: [RedditPost]
        let after: String?
    }

    struct RedditPost: Codable {
        let data: RedditPostData
    }

    struct RedditPostData: Codable {
        let title: String
        //let score: Int
        let numComments: Int
        let createdUtc: TimeInterval
        //let thumbnail: String
        let url: URL
        let author: String
        let ups: Int
        let downs: Int
        let domain: String
        let saved: Bool = Bool.random()
    }
    
    


}

