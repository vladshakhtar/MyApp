//
//  CommentsViewModel.swift
//  CommentsListView
//
//  Created by Vladislav Stolyarov on 30.03.2023.
//
import Foundation

class CommentsViewModel: ObservableObject {
    @Published var comments: [PostCommentData] = []
    var shouldFetchExtraComments : Bool = true
    
    private var parentID: String = "null"
    private var allChildren: [String] = []
    private var childrenToFetch: [String] = []
    private var childrenInString: String = "NOTHING"
    
    private let subreddit : String
    private let postID : String
    
    init(subreddit: String, postID: String) {
        self.subreddit = subreddit
        self.postID = postID
    }
    
    
    func fetchInitialComments() {
        let urlString = "https://www.reddit.com/r/\(subreddit)/comments/\(postID).json?depth=1&limit=10"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Error: no data")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .useDefaultKeys
                let redditAPIResponse = try decoder.decode([RedditCommentAPIResponse].self, from: data)
                
                var comments = redditAPIResponse[1].data.children.map({ $0.data })
                self.allChildren = comments[comments.count - 1].children ?? []
                if self.allChildren.count >= 10 {
                    self.childrenToFetch = Array(self.allChildren[0...9])
                    self.allChildren.removeFirst(10)
                } else {
                    self.childrenToFetch = self.allChildren
                    self.allChildren.removeAll()
                    self.shouldFetchExtraComments = false
                }
                self.childrenInString = self.childrenToFetch.joined(separator: ",")
                self.parentID = comments[comments.count - 1].parent_id ?? "null"
                comments.removeLast()
                DispatchQueue.main.async {
                    self.comments = comments
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    
    func fetchExtraComments(){
        
        if shouldFetchExtraComments {
            let urlString = "https://www.reddit.com/api/morechildren.json?depth=1&link_id=\(parentID)&api_type=json&children=\(childrenInString)"
            guard let url = URL(string: urlString) else { return }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("Error: no data")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .useDefaultKeys
                    let moreCommentsAPIResponse = try decoder.decode(MoreCommentsAPIResponse.self, from: data)
                    
                    var moreComments = moreCommentsAPIResponse.json.data.things.map({ $0.data })
                    moreComments = moreComments.filter({ $0.body != nil })
                    DispatchQueue.main.async {
                        self.comments.append(contentsOf: moreComments)
                    }
                    
                    
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            }.resume()
            
            if self.allChildren.count >= 10 {
                self.childrenToFetch = Array(self.allChildren[0...9])
                self.allChildren.removeFirst(10)
            } else {
                self.childrenToFetch = self.allChildren
                self.allChildren.removeAll()
                self.shouldFetchExtraComments = false
            }
            self.childrenInString = self.childrenToFetch.joined(separator: ",")
            
            
        }
    }
    
}




struct RedditCommentAPIResponse: Codable {
    let kind: String
    let data: RedditFullPostData
}

struct RedditFullPostData: Codable {
    let children : [PostComment]
    let after: String?
}

struct PostComment: Codable {
    let kind: String
    let data: PostCommentData
}

struct PostCommentData: Codable, Identifiable, Hashable {
    let author: String?
    let created: TimeInterval?
    let body: String?
    let ups: Int?
    let downs: Int?
    let id: String?
    let parent_id: String?
    let children: [String]?
    //link
    let permalink:String?
}

struct MoreCommentsAPIResponse : Codable {
    let json: MoreCommentsJSON
}

struct MoreCommentsJSON : Codable {
    let data: MoreComments
}

struct MoreComments : Codable {
    let things : [MoreCommentsData]
}

struct MoreCommentsData : Codable {
    let kind : String
    let data : PostCommentData
}

