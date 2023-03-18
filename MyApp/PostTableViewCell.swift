//
//  PostTableViewCell.swift
//  MyApp
//
//  Created by Vladislav Stolyarov on 05.03.2023.
//

import Foundation
import UIKit


final class PostTableViewCell: UITableViewCell {
    // MARK: - IBOutlet
    

    @IBOutlet weak var redditPost: RedditPostView!
    
    var viewController : UIViewController!

    override func prepareForReuse() {
        super.prepareForReuse()
    }
    

    
    func config(with data:RedditPostDataToSave){
        self.redditPost.parentViewController = viewController
        self.redditPost.giveInfoForLink(data: data)
        self.redditPost.fillView(with: data)
    }
    
    
}
