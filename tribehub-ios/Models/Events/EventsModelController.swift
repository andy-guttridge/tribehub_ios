//
//  EventsManager.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 11/05/2023.
//

import Foundation
import Alamofire

// MARK: EventURLParams Struct definition
struct EventURLParams: Encodable {
    let fromDate: Date?
    let toDate: Date?
    let searchText: String?
    let category: String?
    let tribeMembers: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case fromDate = "from_date"
        case toDate = "to_date"
        case searchText = "search"
        case category = "category"
        case tribeMembers = "to"
    }
}

/// Controller for Events model
class EventsModelController {
    private weak var session: Session?
    private(set) var events: EventResults?
    
    init(withSession session: Session) {
        self.session = session
    }
    
    /// Attempts to fetch events for authenticated user
    func getEvents(
        fromDate: Date? = nil,
        toDate: Date? = nil,
        searchText: String? = nil,
        category: String? = nil,
        tribeMembers: [Int]? = nil
    ) async throws {
        guard let session = self.session else {
            throw SessionError.noSession
        }
        
        let urlParameters = EventURLParams(
            fromDate: fromDate,
            toDate: toDate,
            searchText:searchText,
            category: category,
            tribeMembers: tribeMembers
        )
        
        // Try to fetch user's event data from the API
        let eventsRequest = APIRequest(resource: EventsResource(), session: session)
        do {
            let response = try await eventsRequest.fetchData(urlParameters: urlParameters)
            events = response
        }
    }
    
    /// Attempts to fetch a specific event
    func getEventForPk(_ pk: Int?) async throws -> Event? {
        guard let session = self.session else {
            throw SessionError.noSession
        }
        
        // Try to fetch the event from the API
        let eventRequest = APIRequest(resource: EventResource(), session: session)
        do {
            let response = try await eventRequest.fetchData(forPk: pk)
            return response
        }
    }
    
    /// Handles user's response to an event invitation
    func didRespondToEventForPk(_ pk: Int, isGoing: Bool) async throws {
        guard let session = self.session else {
            throw SessionError.noSession
        }
        let eventResponseRequest = APIRequest(resource: EventResponseResource(), session: session)
        do {
            let payload = ["event_response": isGoing ? "accept" : "decline"]
            _ = try await eventResponseRequest.postData(itemForPrimaryKey: pk, payload: payload)
        }
    }
    
    /// Creates a new event
    func createEvent(
        toPk: [Int?],
        start: Date,
        duration: TimeInterval,
        recurrenceType: EventRecurrenceTypes,
        subject: String,
        category: EventCategories
    ) async throws -> Event? {
        
        guard let session = self.session else {
            throw SessionError.noSession
        }
        
        // Convert event start date, duration, recurrence and category to strings
        let startString = start.ISO8601Format(.iso8601)
        let durationString = intervalToHoursMinsSecondsStr(duration)
        let recurrenceString = recurrenceType.rawValue
        let categoryString = category.rawValue
        
        // Create payload for API request
        let payload = [
            "to": toPk,
            "start": startString,
            "duration": durationString,
            "recurrence_type": recurrenceString,
            "subject": subject,
            "category": categoryString
        ] as [String : Any]
        
        let eventRequest = APIRequest(resource: EventResource(), session: session)
        let event = try await eventRequest.postData(payload: payload)
        return event
    }
    
    /// Makes changes to existing event
    func changeEvent(
        eventPk: Int,
        toPk: [Int?],
        start: Date,
        duration: TimeInterval,
        recurrenceType: EventRecurrenceTypes,
        subject: String,
        category: EventCategories
    ) async throws {
        
        guard let session = self.session else {
            throw SessionError.noSession
        }
        
        // Convert event start date, duration, recurrence and category to strings
        let startString = start.ISO8601Format(.iso8601)
        let durationString = intervalToHoursMinsSecondsStr(duration)
        let recurrenceString = recurrenceType.rawValue
        let categoryString = category.rawValue
        
        // Create payload for API request
        let payload = [
            "to": toPk,
            "start": startString,
            "duration": durationString,
            "recurrence_type": recurrenceString,
            "subject": subject,
            "category": categoryString
        ] as [String : Any]
        
        let eventRequest = APIRequest(resource: EventsResource(), session: session)
        _ = try await eventRequest.putData(itemForPrimaryKey: eventPk, payload: payload)
    }
    
    /// Deletes an existing event
    func deleteEventForPk(_ pk: Int) async throws {
        guard let session = self.session else {
            throw SessionError.noSession
        }
        let eventDeleteRequest = APIRequest(resource: DeleteEventResource(), session: session)
        _ = try await eventDeleteRequest.delete(itemForPrimaryKey: pk)
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
    
    /// Returns any events for a given date
    func getEventsForDateComponents(_ calDateComponents: DateComponents) -> [Event]? {
        guard let events = events?.results else { return nil }
        let calendar = Calendar(identifier: .gregorian)
        
        // Use filter to extract only the events that occur on the date for the calendar components passed in
        let eventsForDay = events.filter() { event in
            guard let eventDate = event.start,  let calDate = calendar.date(from: calDateComponents) else {return false}
            
            // Convert dates for the given event to a date with no time
            let eventComponents = calendar.dateComponents([.day, .month, .year], from: eventDate)
            let eventDateWithNoTime = calendar.date(from: eventComponents)
            
            //Convert date passed in from the calendar to a date with no time, then compare with the event date
            let calDateComponentsWithNoTime = calendar.dateComponents([.day, .month, .year], from: calDate)
            let calDateWithNoTime = calendar.date(from: calDateComponentsWithNoTime)
            return eventDateWithNoTime == calDateWithNoTime
        }
        return eventsForDay
    }
}
