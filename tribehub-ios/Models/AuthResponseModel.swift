//
//  LoginResponse.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 30/03/2023.
//

import Foundation
import Alamofire

public struct DJAuthCredential: Codable, EmptyResponse, AuthenticationCredential {
    
    var accessToken: String?
    var refreshToken: String?
    var user: User?
    let expiration: Date = Date.init(timeIntervalSinceNow: 1 * 10)
    public var requiresRefresh: Bool {
        Date.init() > self.expiration
    }
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case user
    }
    
    public static func emptyValue() -> DJAuthCredential {
        return DJAuthCredential(accessToken: nil, refreshToken: nil, user: nil)
    }
}
