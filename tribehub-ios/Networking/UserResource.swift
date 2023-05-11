//
//  UserResource.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 30/03/2023.
//

import Foundation

// Resource supplies decodable model and API endpoint for user details
class UserResource: APIResource {
    typealias ModelType = User
    var methodPath: String {
        return "dj-rest-auth/user/"
    }
}

