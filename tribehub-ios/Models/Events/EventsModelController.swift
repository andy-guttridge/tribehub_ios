//
//  EventsManager.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 11/05/2023.
//

import Foundation
import Alamofire

/// Controller for Events model
class EventsModelController {
    private weak var session: Session?
    private(set) var events: EventResults?
    
    init(withSession session: Session) {
        self.session = session
    }
    
    /// Attempts to fetch events for authenticated user
    func getEvents() async throws {
        guard let session = self.session else {
            throw SessionError.noSession
        }
        
        // Try to fetch user's event data from the API
        let eventsRequest = APIRequest(resource: EventsResource(), session: session)
        do {
            let response = try await eventsRequest.fetchData()
            events = response
        }
    }
}
