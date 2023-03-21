//
//  ViewController.swift
//  MyApp
//
//  Created by Vladislav Stolyarov on 26.02.2023.
//

import UIKit
import SDWebImage

class PostDetailsViewController: UIViewController {


    @IBOutlet private weak var particularRedditPost: RedditPostView!
    
    var viewController : UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let doubleTapGesture = UITapGestureRecognizer(target: self.particularRedditPost,
                                                      action:
                                                        #selector(RedditPostView.didDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        self.particularRedditPost.addGestureRecognizer(doubleTapGesture)
        
    }
    
    func config(with data: RedditPostDataToSave){
        self.particularRedditPost.parentViewController = viewController
        self.particularRedditPost.giveInfoForLink(data: data)
        self.particularRedditPost.fillView(with: data)
    }
    


}

