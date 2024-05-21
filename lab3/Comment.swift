//
//  Comment.swift
//  lab3
//
//  Created by Viktoriya on 28.04.24.
//

import SwiftUI
struct Comment: Identifiable {
    var id: String
    var itemId: String
    var userId: String
    var userName: String
    var comment: String
    var timestamp: String
}

extension Comment {
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "itemId": itemId,
            "userId": userId,
            "userName": userName,
            "comment": comment,
            "timestamp": timestamp
        ]
    }
    
    static func fromDictionary(_ dictionary: [String: Any]) -> Comment {
        return Comment(
            id: dictionary["id"] as! String,
            itemId: dictionary["itemId"] as! String,
            userId: dictionary["userId"] as! String,
            userName: dictionary["userName"] as! String,
            comment: dictionary["comment"] as! String,
            timestamp: dictionary["timestamp"] as! String
        )
    }
}
