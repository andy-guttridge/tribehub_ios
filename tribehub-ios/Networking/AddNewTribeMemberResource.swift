//
//  AddNewTribeMemberResource.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 28/04/2023.
//

import Foundation

/// Resource supplies decodable model and API endpoint for adding a new tribe member
class AddNewTribeMemberResource: APIResource {
    typealias ModelType = GenericAPIResponse
    var methodPath: String {
        return "accounts/user/"
    }
}
