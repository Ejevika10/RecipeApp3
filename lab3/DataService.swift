//
//  DataService.swift
//  lab3
//
//  Created by Viktoriya on 26.04.24.
//

import Foundation
import FirebaseDatabase
import FirebaseDatabaseSwift
class DataService: ObservableObject{
    public let itemsReference = Database.database().reference().child("items")
    public let usersReference = Database.database().reference().child("users")
    
    init() {
        
    }
    
    func getUser(userId: String, completion: @escaping (MyUser?) -> Void){
        usersReference.child(userId).child("userinfo").observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists(){
                let user = MyUser.fromDictionary((snapshot.value as? [String: Any])!)
                completion(user)
            }
            else{
                completion(nil)
            }
        }
    }
    func saveUser(user: MyUser, userId: String) {
        let ref = usersReference.child(userId).child("userinfo")
        ref.setValue(user.toDictionary())
    }
    func isInFav(userId: String, itemId: String, completion: @escaping (Bool) -> Void) {
        usersReference.child(userId).child("favourites").child(itemId).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    func addToFav(userId: String, itemId: String) {
        let map = ["itemId": itemId, "timestamp": String(NSDate().timeIntervalSince1970)]
        usersReference.child(userId).child("favourites").child(itemId).setValue(map)
    }
    func deleteFromFav(userId: String, itemId: String) {
        usersReference.child(userId).child("favourites").child(itemId).removeValue()
    }
    func getRatings(itemId: String, userId: String, completion: @escaping (Int) -> Void) {
        itemsReference.child(itemId).child("ratings").child(userId).observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    if
                        //let ratingString = snapshot.value as? String,
                       let rating = snapshot.value as? Int {
                        completion(rating)
                    } else {
                        completion(0)
                    }
                } else {
                    completion(0)
                }
        }
    }
    
    func saveRating(item:Item, userId: String, rating: Int) {
        itemsReference.child(item.id).child("ratings").child(userId).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                if let prevRating = snapshot.value as? Int {
                    var avg: Double = (item.avgRating! * Double(item.numOfRatings) - Double(prevRating) + Double(rating)) / Double(item.numOfRatings)
                                       
                    self.itemsReference.child(item.id).child("ratings").child(userId).setValue(rating)
                    self.itemsReference.child(item.id).child("avgRating").setValue(avg)
                }
            } else {
                let avg: Double = (item.avgRating! * Double(item.numOfRatings) + Double(rating)) / Double((item.numOfRatings + 1))
                        self.itemsReference.child(item.id).child("ratings").child(userId).setValue(rating)
                self.itemsReference.child(item.id).child("avgRating").setValue(avg)
                        self.itemsReference.child(item.id).child("numOfRatings").setValue(item.numOfRatings + 1)
            }
        }
    }
    func getNextCommKey(itemId: String) -> String? {
           let key = itemsReference.child(itemId).child("comments").childByAutoId().key
           return key
    }
    
    func saveComment(comment: Comment, itemId: String, key:String) {
        self.itemsReference.child(itemId).child("comments").child(key).setValue(comment.toDictionary())
    }
}
