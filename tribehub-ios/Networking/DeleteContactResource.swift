//
//  DeleteContactResource.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 23/06/2023.
//

import Foundation

/// Resource supplies decodable model and API endpoint for user's contacts
class DeleteContactResource: APIResource {
    typealias ModelType = GenericAPIResponse
    var methodPath: String {
        return "contacts/"
    }
}
