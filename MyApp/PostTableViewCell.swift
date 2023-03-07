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

    override func prepareForReuse() {
        super.prepareForReuse()
    }
    

    
    func config(with data:RedditPostData){
        self.redditPost.fillView(with: data)
    }
    
    
}
