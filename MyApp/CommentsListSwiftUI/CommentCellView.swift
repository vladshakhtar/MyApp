//
//  CommentCellView.swift
//  CommentsListView
//
//  Created by Vladislav Stolyarov on 30.03.2023.
//

import Foundation
import SwiftUI

struct CommentCellView: View {
    let comment: PostCommentData
    
    var body: some View {
        ZStack {
            Rectangle()
                .stroke(Color.gray, lineWidth: 1)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    if let author = comment.author {
                        Text(author)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                    if let created = comment.created {
                        Text(getTimeString(from: created))
                            .foregroundColor(.secondary)
                    }
                }
                if let body = comment.body {
                    Text(body)
                        .foregroundColor(.black)
                }
                HStack {
                    Spacer()
                    if let score = comment.ups, let downvotes = comment.downs {
                        Text("\(score - downvotes)")
                            .foregroundColor(.secondary)
                        Image(systemName: "arrow.up")
                            .foregroundColor(.green)
                        Text("\(score)")
                            .foregroundColor(.secondary)
                        Image(systemName: "arrow.down")
                            .foregroundColor(.red)
                        Text("\(downvotes)")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
            }
            .padding(.horizontal)
        }
    }
}



struct CommentCellView_Previews: PreviewProvider {
    static var previews: some View {
        CommentCellView(comment: PostCommentData(author:"Wasaab",
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





func getTimeString(from timestamp: TimeInterval) -> String {
   let timeElapsed = Int(Date().timeIntervalSince1970 - timestamp)
   if timeElapsed < 60 {
       return "\(timeElapsed) sec. ago"
   } else if timeElapsed < 3600 {
       return "\(timeElapsed / 60) min. ago"
   } else if timeElapsed < 86400 {
       return "\(timeElapsed / 3600) hr. ago"
   } else if timeElapsed < 172800 {
       return "1 day ago"
   }
    else {
        return "\(timeElapsed / 86400) days ago"
    }
}
