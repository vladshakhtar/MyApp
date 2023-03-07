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
     
     func fillView(with data: RedditPostData){
         DispatchQueue.main.async {
             self.titleLabel.text = data.title
             self.commentsCountLabel.text = String(data.numComments)
             self.ratingLabel.text = String(data.ups+data.downs)
             self.usernameLabel.text = data.author
         let timeElapsed = Int(Date().timeIntervalSince1970 - data.createdUtc)
         let timeString: String
         if timeElapsed < 3600 {
             timeString = "\(timeElapsed / 60)m"
         } else if timeElapsed < 86400 {
             timeString = "\(timeElapsed / 3600)h"
         } else {
             timeString = "\(timeElapsed / 86400)d"
         }
             self.timePassedLabel.text = timeString
             self.bookmarkButton.setImage(data.saved ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark"), for: .normal)
             self.redditImage.sd_setImage(with: data.url)
         }
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
