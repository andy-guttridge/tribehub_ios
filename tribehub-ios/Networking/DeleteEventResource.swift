//
//  DeleteEventResource.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 15/06/2023.
//

import Foundation

// Resource supplies decodable model and API endpoint for deleting any user account
class DeleteEventResource: APIResource {
    typealias ModelType = GenericAPIResponse
    var methodPath: String {
        return "events/"
    }
}
