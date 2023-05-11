//
//  DeleteUserResource.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 27/04/2023.
//

import Foundation

// Resource supplies decodable model and API endpoint for deleting any user account
class DeleteUserResource: APIResource {
    typealias ModelType = GenericAPIResponse
    var methodPath: String {
        return "accounts/user/"
    }
}
