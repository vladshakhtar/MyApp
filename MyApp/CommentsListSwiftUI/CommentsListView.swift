//
//  CommentsListView.swift
//  CommentsListView
//
//  Created by Vladislav Stolyarov on 30.03.2023.
//

import Foundation
import SwiftUI




struct CommentsListView: View {
    

    @ObservedObject private var viewModel : CommentsViewModel
    
    init(subreddit: String, postID: String) {
        self.viewModel = CommentsViewModel(subreddit: subreddit, postID: postID)
    }
    
    
    var body: some View {
        
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.comments, id: \.self) { comment in
                        NavigationLink(value: comment){
                            CommentCellView(comment: comment)
                        }
                    }
                    Color.clear
                        .onAppear(){
                            print("fetching extra comments")
                            if viewModel.shouldFetchExtraComments {
                                viewModel.fetchExtraComments()
                            }
                        }
                }
                .navigationDestination(for: PostCommentData.self){ comment in
                    CommentDetailView(comment: comment)
                }
            }
                .onAppear {
                        viewModel.fetchInitialComments()
            }
        }
        
        
    }
}





struct CommentsListView_Previews: PreviewProvider {
    static var previews: some View {
        CommentsListView(subreddit: "ios", postID: "125lbqz")
    }
}

