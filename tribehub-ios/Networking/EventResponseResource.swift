//
//  EventResponseResource.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 25/05/2023.
//

import Foundation

/// Resource supplies decodable model and API endpoint for user's tribe details
class EventResponseResource: APIResource {
    typealias ModelType = GenericAPIResponse
    var methodPath: String {
        return "events/response/"
    }
}
