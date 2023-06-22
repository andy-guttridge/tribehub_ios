//
//  ContactModel.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 22/06/2023.
//

import Foundation


struct Contact: Codable {
    var id: Int?
    var category: String?
    var company: String?
    var title: String?
    var firstName: String?
    var lastName: String?
    var phone: String?
    var email: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case category = "category"
        case company = "company"
        case title = "title"
        case firstName = "first_name"
        case lastName = "last_name"
        case phone = "phone"
        case email = "email"
    }
}

struct ContactResults: Codable {
    var count: Int?
    var results:  [Contact]
}
