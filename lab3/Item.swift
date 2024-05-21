//
//  Item.swift
//  lab3
//
//  Created by Viktoriya on 26.04.24.
//

import SwiftUI

struct Item : Identifiable{
        
    var images: String?
    var diff: String = ""
    var id: String = ""
    var name: String = ""
    var img: String = ""
    var desk: String = ""
    var price: Int = 0
    var time: String = ""
    var avgRating: Double? = 0.0
    var numOfRatings: Int = 0
    
    init(images: String?, diff: String, id: String, name: String, img: String, desk: String, price: Int, time: String, avgRating: Double?, numOfRatings: Int) {
           self.images = images
           self.diff = diff
           self.id = id
           self.name = name
           self.img = img
           self.desk = desk
           self.price = price
           self.time = time
           self.avgRating = avgRating
           self.numOfRatings = numOfRatings
       }
       
       func toDictionary() -> [String: Any] {
           return [
               "images": images ?? "",
               "diff": diff,
               "id": id,
               "name": name,
               "img": img,
               "desk": desk,
               "price": String(price),
               "time": time,
               "avgRating": String(avgRating ?? 0.0),
               "numOfRatings": String(numOfRatings)
           ]
       }
       
       static func fromDictionary(_ value: [String: Any]?) -> Item? {
           guard let value = value else { return nil }
           
           return Item(images: value["images"] as? String,
                         diff: value["diff"] as! String,
                         id: value["id"] as! String,
                         name: value["name"] as! String,
                         img: value["img"] as! String,
                         desk: value["desk"] as! String,
                         price: value["price"] as! Int,
                         time: value["time"] as! String,
                         avgRating: value["avgRating"] as! Double,
                         numOfRatings: value["numOfRatings"] as! Int)
       }
}


