//
//  AddNewEventResource.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 04/06/2023.
//

import Foundation

/// Resource supplies decodable model and API endpoint for adding a new event
class AddOrEditNewEventResource: APIResource {
    typealias ModelType = GenericAPIResponse
    var methodPath: String {
        return "accounts/user/"
    }
}
