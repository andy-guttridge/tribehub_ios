//
//  models.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 24/03/2023.
//

import Foundation
import UIKit

public struct User: Codable {
    var pk: Int?
    var userName: String?
    var profileImageURL: String?
    var profileImage: UIImage?
    var displayName: String?
    var isAdmin: Bool?
    var tribeName: String?
    
    enum CodingKeys: String, CodingKey {
        case pk
        case userName = "username"
        case profileImageURL = "profile_image"
        case isAdmin = "is_admin"
        case displayName = "display_name"
        case tribeName = "tribe_name"
    }
}
