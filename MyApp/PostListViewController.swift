//
//  PostListViewController.swift
//  MyApp
//
//  Created by Vladislav Stolyarov on 05.03.2023.
//

import Foundation
import UIKit
import SDWebImage


class PostListViewController: UITableViewController {
    
    //MARK: IBOutlets
    
    @IBOutlet weak var subRedditView: UIView!
    
    @IBOutlet weak var subRedditTitleLabel: UILabel!
        
    @IBOutlet weak var circledBookmarkButton: UIButton!
    //MARK: Const
    struct Const {
        static let cellReuseIdentifier = "PostTableViewCell"
        static let goToPostDetailsSegueID = "GoToPostDetails"
    }
    
    
    
    //MARK: Properties data
    var dataToPost: [RedditPostData] = []
    var isLoading = false
    var after: String?
    var lastSelectedPost: RedditPostData?
    
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: Const.cellReuseIdentifier)
        loadData()

    }
    
    //MARK: Navigation
    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?) {
            switch segue.identifier {
            case Const.goToPostDetailsSegueID:
                let nextVc = segue.destination as! PostDetailsViewController
                DispatchQueue.main.async {
                    nextVc.config(with: self.lastSelectedPost ?? self.dataToPost[0])

                }
            default: break
            }
    }

    
    
    // MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataToPost.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Const.cellReuseIdentifier,
            for: indexPath) as! PostTableViewCell
        
        cell.config(with: dataToPost[indexPath.row])
        
        
        return cell
        
    }
    
    
    //MARK: UITableViewDelegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let visibleHeight = scrollView.frame.height
            
            if offsetY > contentHeight - visibleHeight * 2 {
                // load the next page of posts
                loadData()
            }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lastSelectedPost = dataToPost[indexPath.row]
        //print("Did select row number: \(indexPath.row)")
        self.performSegue(
            withIdentifier: Const.goToPostDetailsSegueID, sender: nil
        )
    }
    
    
    
    
    
    //MARK: Fuction to load required info
    func loadData() {
        // make sure we're not already loading a page
        guard !isLoading else {
            return
        }
        isLoading = true
        
        // construct the URL for the next page of posts
        var urlComponents = URLComponents(string: "https://www.reddit.com/r/ios/top.json")!
        urlComponents.queryItems = [
            URLQueryItem(name: "limit", value: "15"),
            URLQueryItem(name: "after", value: after) // <-- update the after parameter
        ]
        guard let url = urlComponents.url else {
            return
        }
        
        // make the request for the next page of posts
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            // handle the response
            defer {
                self.isLoading = false
            }
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
                    self.after = redditAPIResponse.data.after // update the "after" parameter for the next request
                    let newPosts = redditAPIResponse.data.children.map { $0.data }
                    self.dataToPost.append(contentsOf: newPosts) // <-- add new posts to the existing array
                    DispatchQueue.main.async {
                        self.tableView.reloadData() // update the table view with the new data
                    }
                } catch {
                    print("Error decoding JSON: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    
}







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


