//
//  UpdatePasswordResource.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 30/04/2023.
//

import Foundation

// Resource supplies decodable model and API endpoint for updating the user's password
class UpdatePasswordResource: APIResource {
    typealias ModelType = GenericAPIResponse
    var methodPath: String {
        return "dj-rest-auth/password/change/"
    }
}
