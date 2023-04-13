//
//  TribeModel.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 24/03/2023.
//

import Foundation
import UIKit

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

struct Tribe: Codable {
    var tribeName: String?
    var tribeMembers: [TribeMember]
    
    enum CodingKeys: String, CodingKey {
        case tribeName = "name"
        case tribeMembers = "users"
    }
}

struct TribeResults: Codable {
    var results: [Tribe]
    
    enum CodingKeys: String, CodingKey {
        case results
    }
}
