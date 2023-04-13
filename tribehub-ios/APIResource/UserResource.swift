//
//  UserResource.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 30/03/2023.
//

import Foundation

class UserResource: APIResource {
    typealias ModelType = User
    var methodPath: String {
        return "dj-rest-auth/user/"
    }
}

