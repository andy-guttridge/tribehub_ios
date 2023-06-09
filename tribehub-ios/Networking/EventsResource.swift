//
//  File.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 11/05/2023.
//

import Foundation

/// Resource supplies decodable model and API endpoint for user's events
class EventsResource: APIResource {
    typealias ModelType = EventResults
    var methodPath: String {
        return "events/"
    }
}
