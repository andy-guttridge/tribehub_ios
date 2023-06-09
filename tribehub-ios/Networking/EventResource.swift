//
//  EventResource.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 09/06/2023.
//

import Foundation

/// Resource supplies decodable model and API endpoint for a single event
class EventResource: APIResource {
    typealias ModelType = Event
    var methodPath: String {
        return "events/"
    }
}
