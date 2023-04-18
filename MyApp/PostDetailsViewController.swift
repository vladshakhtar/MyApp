//
//  ViewController.swift
//  MyApp
//
//  Created by Vladislav Stolyarov on 26.02.2023.
//

import UIKit
import SwiftUI
import SDWebImage

class PostDetailsViewController: UIViewController {

    enum Const {
        static let goToCommentDetailsSegueID = "GoToCommentDetails"
    }

    @IBOutlet private weak var particularRedditPost: RedditPostView!
    
    @IBOutlet private weak var commentsList: UIView!
    
    var viewController : UIViewController!
    
    var dataForComment : RedditPostDataToSave?


    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let doubleTapGesture = UITapGestureRecognizer(target: self.particularRedditPost,
                                                      action:
                                                        #selector(RedditPostView.didDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        
        self.particularRedditPost.addGestureRecognizer(doubleTapGesture)
        
        DispatchQueue.main.async {
            
            if let dataForComment = self.dataForComment {
                
                
                let commentsListViewController : UIViewController = UIHostingController(rootView: CommentsListView(
                    subreddit: dataForComment.subreddit,
                    postID: dataForComment.id))
                
                let commentsListView : UIView = commentsListViewController.view
                
                self.commentsList.addSubview(commentsListView)
                
                commentsListView.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    commentsListView.topAnchor.constraint(equalTo: self.commentsList.topAnchor),
                    commentsListView.trailingAnchor.constraint(equalTo: self.commentsList.trailingAnchor),
                    commentsListView.bottomAnchor.constraint(equalTo: self.commentsList.bottomAnchor),
                    commentsListView.leadingAnchor.constraint(equalTo: self.commentsList.leadingAnchor)
                ])
                
                commentsListViewController.didMove(toParent: self)
                
                
            }
        }
        
        
    }
    
    func config(with data: RedditPostDataToSave){
        self.dataForComment = data
        self.particularRedditPost.parentViewController = viewController
        self.particularRedditPost.giveInfoForLink(data: data)
        self.particularRedditPost.fillView(with: data)
    }
    
    
    
    
    
    
    // MARK: - Navigation
//    override func prepare(
//        for segue: UIStoryboardSegue,
//        sender: Any?) {
//            switch segue.identifier {
//            case Const.goToCommentDetailsSegueID:
//                let nextVc = segue.destination as! CommentDetailsViewController
//                DispatchQueue.main.async {
//                    if let dataForSegue = self.dataForSegue {
//                        nextVc.config(with: dataForSegue)
//                    }
//                }
//            default: break
//            }
//    }
    


}

