//
//  PostListViewController.swift
//  MyApp
//
//  Created by Vladislav Stolyarov on 05.03.2023.
//

import Foundation
import UIKit
import SDWebImage


class PostListViewController: UITableViewController, UITextFieldDelegate {
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var subRedditView: UIView!
    
    @IBOutlet private weak var subRedditTitleLabel: UILabel!
        
    @IBOutlet private weak var circledBookmarkButton: UIButton!
    
    @IBOutlet private weak var titleSearch: UITextField!
    
    //MARK: - Const
    
    enum Const {
        static let cellReuseIdentifier = "PostTableViewCell"
        static let goToPostDetailsSegueID = "GoToPostDetails"
        static let savedPostButtonImageSystemName = "bookmark.circle.fill"
        static let nonSavedPostButtonImageSystemName = "bookmark.circle"
        static let fileWithSavedPostsName = "saved_reddit_posts.json"
    }
    
    //MARK: - IBAction
    
    @IBAction func showSavedPosts(_ sender: Any) {
        if self.circledBookmarkButton.currentImage == UIImage(systemName: Const.nonSavedPostButtonImageSystemName){
            loadDataFromDisk()
            self.circledBookmarkButton.setImage(UIImage(systemName: Const.savedPostButtonImageSystemName), for: .normal)
            self.titleSearch.isHidden = false
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        } else {
            self.circledBookmarkButton.setImage(UIImage(systemName: Const.nonSavedPostButtonImageSystemName), for: .normal)
            self.titleSearch.isHidden = true
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
    //MARK: Properties data
    var dataToPost: [RedditPostDataToSave] = []
    var savedDataToPost: [RedditPostDataToSave] = []
    var filteredPosts: [RedditPostDataToSave] = []
    var isLoading = false
    var after: String?
    var lastSelectedPost: RedditPostDataToSave?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleSearch.delegate = self
//        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: Const.cellReuseIdentifier)
        self.circledBookmarkButton.setImage(UIImage(systemName: Const.nonSavedPostButtonImageSystemName), for: .normal)
        self.titleSearch.isHidden = true
        loadDataFromDisk()
        loadData()
        filteredPosts = savedDataToPost
    }
    
    //MARK: - Navigation
    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?) {
            switch segue.identifier {
            case Const.goToPostDetailsSegueID:
                let nextVc = segue.destination as! PostDetailsViewController
                DispatchQueue.main.async {
                    nextVc.viewController = self
                    nextVc.config(with: self.lastSelectedPost ?? self.dataToPost[0])

                }
            default: break
            }
    }

    
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.circledBookmarkButton.currentImage == UIImage(systemName: Const.nonSavedPostButtonImageSystemName){
        return dataToPost.count
        } else {
            return filteredPosts.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Const.cellReuseIdentifier,
            for: indexPath) as! PostTableViewCell
        
        cell.viewController = self
        
        let doubleTapGesture = UITapGestureRecognizer(target: cell.redditPost,
                                                      action:
                                                        #selector(RedditPostView.didDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        cell.redditPost.addGestureRecognizer(doubleTapGesture)
        
        let singleTapGesture = UITapGestureRecognizer(target: self,
                                                      action:
                                                        #selector(didSingleTap(_:)))
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.require(toFail: doubleTapGesture)
        cell.addGestureRecognizer(singleTapGesture)
        
        if self.circledBookmarkButton.currentImage == UIImage(systemName: Const.nonSavedPostButtonImageSystemName){
        cell.config(with: dataToPost[indexPath.row])
        } else {
            cell.config(with: filteredPosts[indexPath.row])
        }
        
        return cell
        
    }
    
    @objc func didSingleTap(_ sender: UITapGestureRecognizer) {
        if let cell = sender.view as? PostTableViewCell,
           let indexPath = tableView.indexPath(for: cell) {
            if self.circledBookmarkButton.currentImage == UIImage(systemName: Const.nonSavedPostButtonImageSystemName){
                lastSelectedPost = dataToPost[indexPath.row]
            } else {
                lastSelectedPost = filteredPosts[indexPath.row]
            }
            self.performSegue(
                withIdentifier: Const.goToPostDetailsSegueID, sender: nil
            )
        }
    }
    
    
    //MARK: UITableViewDelegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let visibleHeight = scrollView.frame.height
            
            if offsetY > contentHeight - visibleHeight * 2 {
                if self.circledBookmarkButton.currentImage == UIImage(systemName: Const.nonSavedPostButtonImageSystemName){
                    loadData()
                }
            }
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if self.circledBookmarkButton.currentImage == UIImage(systemName: Const.nonSavedPostButtonImageSystemName){
//        lastSelectedPost = dataToPost[indexPath.row]
//        } else {
//            lastSelectedPost = filteredPosts[indexPath.row]
//        }
//        self.performSegue(
//            withIdentifier: Const.goToPostDetailsSegueID, sender: nil
//        )
//    }
    


    

    //MARK: UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentSearchString = textField.text ?? ""
        let newSearchString = (currentSearchString as NSString).replacingCharacters(in: range, with: string)
        
        if newSearchString.isEmpty  {
                filteredPosts = savedDataToPost
            } else {
                filteredPosts = savedDataToPost.filter { $0.title.range(of: newSearchString, options: .caseInsensitive) != nil
                }
            }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        return true
    }
    
    
    //MARK: Fuction to load required info
    func loadData() {
        guard !isLoading else {
            return
        }
        isLoading = true

        let request = RedditAPIRequest(path: "/r/ios/top.json", limit: 15, after: after)

        guard let url = request.url else {
            return
        }
        let urlSession = URLSession(configuration: .ephemeral)
        let task = urlSession.dataTask(with: url) { (data, response, error) in
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
                    self.after = redditAPIResponse.data.after
                    let newPosts = redditAPIResponse.data.children.map { $0.data }
                    var mappedPosts = newPosts.map {mapDownloadedDataWithDataToSave(downloadedData: $0)}
                    for i in 0..<mappedPosts.count {
                        if self.savedDataToPost.contains(mappedPosts[i]){
                            mappedPosts[i].saved = true
                        }
                    }
                    self.dataToPost.append(contentsOf: mappedPosts)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } catch {
                    print("Error decoding JSON: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    
    
    //MARK: Save, Load And Delete Data Locally
    
    func saveDataToDisk(_ data: RedditPostDataToSave) {
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .useDefaultKeys
            let jsonData = try encoder.encode(data)
            let fileManager = FileManager.default
            let documentsDirectory = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
            
            let fileURL = documentsDirectory.appendingPathComponent(Const.fileWithSavedPostsName)
            
            if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                            fileHandle.seekToEndOfFile()
                            fileHandle.write(jsonData)
                            fileHandle.write("\n".data(using: .utf8)!)
                            fileHandle.closeFile()
                    } else {
                        try jsonData.write(to: fileURL)
                    }
                    
                    print("Success saving!")
                } catch {
                    print("Error saving data to file: \(error.localizedDescription)")
                }
        
    }
    
    func loadDataFromDisk() {
        do {
            let fileManager = FileManager.default
            let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentsDirectory.appendingPathComponent(Const.fileWithSavedPostsName)
            
            if !fileManager.fileExists(atPath: fileURL.path) {
                print("File does not exist at path: \(fileURL)")
                return
            }
            
            let jsonData = try String(contentsOf: fileURL)
            let lines = jsonData.split(separator: "\n")
            if jsonData.isEmpty {
                print("File at path \(fileURL) is empty.")
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            var data: [RedditPostDataToSave] = []
            for line in lines {
                        if let lineData = line.data(using: .utf8),
                           let post = try? decoder.decode(RedditPostDataToSave.self, from: lineData) {
                            data.append(post)
                        }
                    }
            print("Data loaded succesfully!")
            for post in data {
                if !savedDataToPost.contains(post){
                    savedDataToPost.append(post)
                }
            }
            filteredPosts = savedDataToPost
            
        } catch {
            print("Error loading data from file: \(error.localizedDescription)")
        }
    }

    
    func deleteDataFromDisk(_ postToDelete: RedditPostDataToSave) {
        do {
            let fileManager = FileManager.default
            let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentsDirectory.appendingPathComponent(Const.fileWithSavedPostsName)
            
            if !fileManager.fileExists(atPath: fileURL.path) {
                print("File does not exist at path: \(fileURL)")
                return
            }
            
            let jsonData = try String(contentsOf: fileURL)
            let lines = jsonData.split(separator: "\n")
            if jsonData.isEmpty {
                print("File at path \(fileURL) is empty.")
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            var data: [RedditPostDataToSave] = []
            for line in lines {
                        if let lineData = line.data(using: .utf8),
                           let post = try? decoder.decode(RedditPostDataToSave.self, from: lineData) {
                            if post != postToDelete{
                            data.append(post)
                            }
                        }
                    }
            
            if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                        fileHandle.truncateFile(atOffset: 0)
                        for post in data {
                            let postData = try JSONEncoder().encode(post)
                            fileHandle.write(postData)
                            fileHandle.write("\n".data(using: .utf8)!)
                        }
                        fileHandle.closeFile()
                    } else {
                        let jsonData = try JSONEncoder().encode(data)
                        try jsonData.write(to: fileURL)
                    }
            
            for i in 0..<savedDataToPost.count{
                if savedDataToPost[i] == postToDelete{
                    for j in 0..<filteredPosts.count{
                        if filteredPosts[j] == savedDataToPost[i]{
                            filteredPosts.remove(at: j)
                        }
                    }
                    savedDataToPost.remove(at: i)
                }
            }
            
            print("Success deleting of data!")
            
        } catch {
            print("Error deleting data from file: \(error.localizedDescription)")
        }
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
    //data to show
    let title: String
    let numComments: Int
    let createdUtc: TimeInterval
    let url: URL
    let author: String
    let ups: Int
    let downs: Int
    let domain: String
    var saved: Bool = false
    
   //data for permalink
    let subreddit: String
    let id: String
    
}

struct RedditPostDataToSave: Codable, Equatable {
    var title: String
    var numComments: String
    var timePassed: String
    var url: URL
    var author: String
    var rating: String
    var domain: String
    var saved: Bool
    
    //data for permalink
    var subreddit: String
    var id: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case numComments = "num_comments"
        case timePassed = "time_passed"
        case url
        case author
        case rating
        case domain
        case saved
        case subreddit
        case id
    }
    
    static func == (lhs: RedditPostDataToSave, rhs: RedditPostDataToSave) -> Bool {
            return lhs.title == rhs.title
        }
}


func mapDownloadedDataWithDataToSave(downloadedData: RedditPostData) -> RedditPostDataToSave {
    let timeElapsed = Int(Date().timeIntervalSince1970 - downloadedData.createdUtc)
            let timeString: String
            if timeElapsed < 3600 {
                timeString = "\(timeElapsed / 60)m"
            } else if timeElapsed < 86400 {
                timeString = "\(timeElapsed / 3600)h"
            } else {
                timeString = "\(timeElapsed / 86400)d"
            }
    let postDataToSave = RedditPostDataToSave(title: downloadedData.title,
                                              numComments: String(downloadedData.numComments),
                                              timePassed: timeString,
                                              url: downloadedData.url,
                                              author: downloadedData.author,
                                              rating: String(downloadedData.ups+downloadedData.downs),
                                              domain: downloadedData.domain,
                                              saved: downloadedData.saved,
                                              subreddit: downloadedData.subreddit,
                                              id: downloadedData.id)
    return postDataToSave
}


    
    


