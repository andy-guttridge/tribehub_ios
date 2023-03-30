//
//  LoginResponse.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 30/03/2023.
//

import Foundation
import Alamofire

public struct LoginResponse: Codable, EmptyResponse {
    
    var accessToken: String?
    var refreshToken: String?
    var user: User?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case user
    }
    
    public static func emptyValue() -> LoginResponse {
        return LoginResponse(accessToken: nil, refreshToken: nil, user: nil)
    }
}
