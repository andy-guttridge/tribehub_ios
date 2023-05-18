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
    
    /// Checks whether there are any events for a given date
    func checkEventsForDateComponents(_ dateComponents: DateComponents) -> Bool? {
        guard let events = events?.results else { return nil }
        
        // Convert date components to a date object
        let calendarDate = Calendar(identifier: .gregorian).date(from: dateComponents)
        
        // Reduce the array of events to a single bool to indicate whether there are any events on the given date
        let dayHasEvents: Bool = events.reduce(false) { acc, event in
            guard let eventDate = event.start else {return acc || false}
            
            // Convert the event to a date with no time data
            let calendar = Calendar(identifier: .gregorian)
            let eventComponents = calendar.dateComponents([.day, .month, .year], from: eventDate)
            let eventDateWithNoTime = calendar.date(from: eventComponents)
            
            // Check whether the event date and the date from the calendar match, and OR with the accumulator
            // to ensure we return true if we've previously found a match, even if we didn't this time
            
            return acc || eventDateWithNoTime == calendarDate
        }
        return dayHasEvents
    }
}
