//
//  CommentDetailVIew.swift
//  CommentsListView
//
//  Created by Vladislav Stolyarov on 30.03.2023.
//

import Foundation
import SwiftUI

struct CommentDetailView: View {
    let comment: PostCommentData
    
    
    var body: some View {
        VStack(spacing: 0) {
            CommentCellView(comment: comment)
            Spacer()
            if let permalink = comment.permalink {
                ShareLink(item: URL(string: "https://www.reddit.com\(permalink)")!){
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
        }
    }
}


struct CommentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CommentDetailView(comment: PostCommentData(author:"Wasaab",
                                                   created: 1680089947,
                                                   body: "Was the phone running hot when running Geekbench?  CPU might have been throttled because of that.",
                                                   ups: 122,
                                                   downs: 0,
                                                   id: "je4ls05",
                                                                        parent_id: "Nothing",
                                                                        children: [],
                                                                        permalink: "/r/ios/comments/125lbqz/ios_164_on_iphone_13_significant_drop_in/je4ls05/"))
    }
}




