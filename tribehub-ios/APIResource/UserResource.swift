//
//  UserResource.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 30/03/2023.
//

import Foundation

struct UserResource: APIResource {
    typealias ModelType = User
    typealias APIResponseType = LoginResponse
    var requestType: UserAPIRequestTypes = .profile
    var methodPath: String {
        switch requestType {
        case .login:
            return "dj-rest-auth/login/"
        case .logout:
            return "dj-rest-auth/logout/"
        case .profile:
            return "dj-rest-auth/user/"
        }
    }
    init(requestType: UserAPIRequestTypes) {
        self.requestType = requestType
    }
}
