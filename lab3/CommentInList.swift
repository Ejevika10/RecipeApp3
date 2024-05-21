//
//  CommentInList.swift
//  lab3
//
//  Created by Viktoriya on 28.04.24.
//

import SwiftUI

struct CommentInList: View {
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                Text(comment.userName)
                    .font(.system(size: 30))
            }
            .padding(10)
            
            Text(comment.comment)
                .font(.system(size: 20))
                .padding([.horizontal, .bottom], 15)
            let date = Date(timeIntervalSince1970: TimeInterval(comment.timestamp)!).description
            
            Text(date.prefix(10))
                .font(.system(size: 17))
                .padding(20)
                .multilineTextAlignment(.trailing)
        }
        .background(Color.white)
        .cornerRadius(10)
        .padding(10)
    }
}
