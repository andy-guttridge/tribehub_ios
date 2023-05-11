//
//  TribeModel.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 24/03/2023.
//

import Foundation
import UIKit

/// Model for an individual tribe member
struct TribeMember: Codable {
    var pk: Int?
    var displayName: String?
    var profileImageURL: String?
    var profileImage: UIImage?
    
    enum CodingKeys: String, CodingKey {
        case pk = "user_id"
        case displayName = "display_name"
        case profileImageURL = "profile_image"
    }
}

/// Model for the array of tribe members supplied by the API
struct Tribe: Codable {
    var tribeName: String?
    var tribeMembers: [TribeMember]
    
    enum CodingKeys: String, CodingKey {
        case tribeName = "name"
        case tribeMembers = "users"
    }
}

/// Model for the results array containing the tribe array supplied by the API
struct TribeResults: Codable {
    var results: [Tribe]
    
    enum CodingKeys: String, CodingKey {
        case results
    }
}
