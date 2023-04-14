//
//  LoginResource.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 13/04/2023.
//

import Foundation

class LoginResource: APIResource {
    typealias ModelType = DJAuthCredential
    var methodPath: String {
        return "dj-rest-auth/login/"
    }
}
