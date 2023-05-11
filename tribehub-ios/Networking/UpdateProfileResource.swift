//
//  UpdateProfileResource.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 30/04/2023.
//

import Foundation

// Resource supplies decodable model and API endpoint for updating a user's profile
class UpdateProfileResource: APIResource {
    typealias ModelType = GenericAPIResponse
    var methodPath: String {
        return "profile/"
    }
}
