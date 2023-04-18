//
//  CommentDetailsViewController.swift
//  MyApp
//
//  Created by Vladislav Stolyarov on 15.04.2023.
//

import UIKit
import SwiftUI

class CommentDetailsViewController: UIViewController {

    @IBOutlet private weak var commentDetails: UIView!
    
    private var dataDorComment : PostCommentData?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            if let dataDorComment = self.dataDorComment {
                
                
                let commentDetailsSwiftUIViewController: UIViewController = UIHostingController(rootView: CommentDetailView(comment: dataDorComment))
                
                let commentDetailView : UIView = commentDetailsSwiftUIViewController.view
                
                self.commentDetails.addSubview(commentDetailView)
                
                commentDetailView.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    commentDetailView.topAnchor.constraint(equalTo: self.commentDetails.topAnchor),
                    commentDetailView.trailingAnchor.constraint(equalTo: self.commentDetails.trailingAnchor),
                    commentDetailView.bottomAnchor.constraint(equalTo: self.commentDetails.bottomAnchor),
                    commentDetailView.leadingAnchor.constraint(equalTo: self.commentDetails.leadingAnchor)
                ])
                
                commentDetailsSwiftUIViewController.didMove(toParent: self)
                
            }
        }
    }
    
    func config(with data: PostCommentData){
        self.dataDorComment = data
    }

}

