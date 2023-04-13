//
//  LoginResource.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 13/04/2023.
//

import Foundation

class LoginResource: APIResource {
    typealias ModelType = AuthResponse
    var methodPath: String {
        return "dj-rest-auth/login/"
    }
}
