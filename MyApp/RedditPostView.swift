//
//  RedditPost.swift
//  MyApp
//
//  Created by Vladislav Stolyarov on 05.03.2023.
//

import Foundation
import UIKit


 class RedditPostView: UIView {
    
    
    let kCONTENT_XIB_NAME = "RedditPostView"
    
    
    @IBOutlet weak var postView: UIView!
    
    @IBOutlet  private weak var shareButton: UIButton!
    
    @IBOutlet  private weak var usernameLabel: UILabel!
    
    @IBOutlet  private weak var domainLabel: UILabel!
    
    @IBOutlet  private weak var titleLabel: UILabel!
    
    @IBOutlet  private weak var timePassedLabel: UILabel!
    
    @IBOutlet  private weak var ratingLabel: UILabel!
    
    @IBOutlet  private weak var commentsCountLabel: UILabel!
    
    @IBOutlet  private weak var bookmarkButton: UIButton!
    
    @IBOutlet  private weak var redditImage: UIImageView!
     
    private var dataForLink: infoForLink?
     
    private var imageURL: URL!
     
    var parentViewController: UIViewController!
     
    
    
     override init(frame: CGRect) {
         super.init(frame: frame)
         commonInit()
     }

     required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
         commonInit()
     }

     private func commonInit() {
         Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
         postView.fixInView(self)
     }
     
     func fillView(with data: RedditPostDataToSave){
         DispatchQueue.main.async {
             self.titleLabel.text = data.title
             self.commentsCountLabel.text = data.numComments
             self.ratingLabel.text = data.rating
             self.usernameLabel.text = data.author
             self.domainLabel.text = data.domain
             self.timePassedLabel.text = data.timePassed
             self.bookmarkButton.setImage(data.saved ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark"), for: .normal)
             self.redditImage.sd_setImage(with: data.url)
             
             
         }
     }
     
     typealias infoForLink = (subReddit: String, id: String)
     
     
     func giveInfoForLink(data: RedditPostDataToSave){
         DispatchQueue.main.async {
             self.dataForLink = (data.subreddit, data.id)
             self.imageURL = data.url
         }
     }
     
     
     
     //MARK: IBAction
     @IBAction func sharePost(_ sender: Any) {

         guard let dataForLink = dataForLink else {
             return
         }

         
         let postURLString = "https://www.reddit.com/r/\(dataForLink.subReddit)/comments/\(dataForLink.id)"
         
         guard let postURL = URL(string: postURLString) else {
             return
         }
         
         let activityItems = [postURL]
         DispatchQueue.main.async {
         let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
             self.parentViewController.present(activityViewController, animated: true, completion: nil)
         }
     }
     
     @IBAction func savePost(_ sender: Any) {
         
         let plvc = parentViewController as! PostListViewController
         
         if self.bookmarkButton.currentImage == UIImage(systemName: "bookmark"){
             self.bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
             for i in 0..<plvc.dataToPost.count {
                 if plvc.dataToPost[i].title == self.titleLabel.text{
                     plvc.dataToPost[i].saved = true
                     plvc.saveDataToDisk(RedditPostDataToSave(title: self.titleLabel.text!,
                                                              numComments: self.commentsCountLabel.text!,
                                                              timePassed: self.timePassedLabel.text!,
                                                              url: self.imageURL,
                                                              author: self.usernameLabel.text!,
                                                              rating: self.ratingLabel.text!,
                                                              domain: self.domainLabel.text!,
                                                              saved: true,
                                                              subreddit: dataForLink!.subReddit,
                                                              id: dataForLink!.id))
                     DispatchQueue.main.async {
                         plvc.tableView.reloadData()
                     }
                 }
             }
             
         } else {
             self.bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
             for i in 0..<plvc.dataToPost.count {
                 if plvc.dataToPost[i].title == self.titleLabel.text{
                     plvc.dataToPost[i].saved = false
                     for j in 0..<plvc.savedDataToPost.count {
                         if plvc.dataToPost[i] == plvc.savedDataToPost[j]{
                             plvc.savedDataToPost[j].saved = false
                         }
                     }
                 }
             }
             plvc.deleteDataFromDisk(RedditPostDataToSave(title: self.titleLabel.text!,
                                                          numComments: self.commentsCountLabel.text!,
                                                          timePassed: self.timePassedLabel.text!,
                                                          url: self.imageURL,
                                                          author: self.usernameLabel.text!,
                                                          rating: self.ratingLabel.text!,
                                                          domain: self.domainLabel.text!,
                                                          saved: false,
                                                          subreddit: dataForLink!.subReddit,
                                                          id: dataForLink!.id))
             DispatchQueue.main.async {
                 plvc.tableView.reloadData()
             }
         }
     }
     
     
     
     @objc func didDoubleTap(_ gesture : UITapGestureRecognizer){
         guard let view = self.redditImage else {
                      return
                  }
              let bookmarkView = BookmarkView(frame: CGRect(x: (view.frame.size.width-40)/2,
                                                            y: (view.frame.size.height-40)/2,
                                                            width: 40,
                                                            height: 40))
              view.addSubview(bookmarkView)
              
              bookmarkView.alpha = 0
              
                  UIView.animate(withDuration: 0.5,animations: {
                      bookmarkView.alpha = 1
                  }, completion: { done in
                      if done {
                          UIView.animate(withDuration: 0.5, animations: {
                              bookmarkView.alpha = 0
                          }, completion: {done in
                              if done {
                                  bookmarkView.removeFromSuperview()
                              }
                          })
                      }
                  })
              
         DispatchQueue.main.asyncAfter(deadline: .now()+1 , execute: {
              if self.bookmarkButton.currentImage == UIImage(systemName: "bookmark") {
                  self.bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
                  let plvc = self.parentViewController as! PostListViewController

                  for i in 0..<plvc.dataToPost.count {
                      if plvc.dataToPost[i].title == self.titleLabel.text{
                          plvc.dataToPost[i].saved = true
                          plvc.saveDataToDisk(RedditPostDataToSave(title: self.titleLabel.text!,
                                                                   numComments: self.commentsCountLabel.text!,
                                                                   timePassed: self.timePassedLabel.text!,
                                                                   url: self.imageURL,
                                                                   author: self.usernameLabel.text!,
                                                                   rating: self.ratingLabel.text!,
                                                                   domain: self.domainLabel.text!,
                                                                   saved: true,
                                                                   subreddit: self.dataForLink!.subReddit,
                                                                   id: self.dataForLink!.id))
                          DispatchQueue.main.async {
                              plvc.tableView.reloadData()
                          }
                      }
                  }

              }
     })
              
          }

}


extension UIView
{
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
    
}


