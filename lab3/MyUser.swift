//
//  MyUser.swift
//  lab3
//
//  Created by Viktoriya on 28.04.24.
//

import SwiftUI

struct MyUser {
    var name: String
    var surname: String
    var gender: Bool? = false
    var email: String
    var birthdate: String? = ""
    var favRecipe: String? = ""
    var address: String? = ""
    var phone: String? = ""
    var vegeterian: Bool? = false
    var skill: Int? = 0
    
    init(name: String,surname: String,gender: Bool?,email: String,birthdate: String?,favRecipe: String?,address:String?,phone: String?, vegeterian: Bool?,skill: Int?) {
        self.name = name
        self.surname = surname
        self.gender = gender ?? false
        self.email = email
        self.birthdate = birthdate ?? ""
        self.favRecipe = favRecipe ?? ""
        self.address = address ?? ""
        self.phone = phone ?? ""
        self.vegeterian = vegeterian ?? false
        self.skill = skill ?? 0
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "surname": surname,
            "email": email,
            "gender": gender ?? false,
            "birthdate": birthdate ?? "",
            "favRecipe": favRecipe ?? "",
            "address" : address ?? "",
            "phone" : phone ?? "",
            "vegeterian" : vegeterian ?? false,
            "skill" : skill ?? 0
        ]
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> MyUser {
        return MyUser(
            name: dict["name"] as! String,
            surname: dict["surname"] as! String,
            gender: dict["gender"] as? Bool,
            email: dict["email"] as! String,
            birthdate: dict["birthdate"] as? String,
            favRecipe: dict["favRecipe"] as? String,
            address: dict["address"] as? String,
            phone: dict["phone"] as? String,
            vegeterian: dict["vegeterian"] as? Bool,
            skill: dict["skill"] as? Int
        )
    }
}
