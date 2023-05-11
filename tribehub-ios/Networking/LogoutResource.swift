//
//  LogoutResource.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 13/04/2023.
//

import Foundation

// Resource supplies decodable model and API endpoint for logging out
class LogoutResource: APIResource {
    typealias ModelType = AuthResponse
    var methodPath: String {
        return "dj-rest-auth/logout/"
    }
}
