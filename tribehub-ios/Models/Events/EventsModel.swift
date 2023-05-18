//
//  EventsModel.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 11/05/2023.
//

import Foundation

struct Event: Codable {
    var id: Int?
    var owner: TribeMember?
    var to: [TribeMember]?
    var start: Date?
    var durationString: String?
    var duration: TimeInterval? {
        // Compute the duration of the event from the durationString supplied by the API
        
        // Split the string into array of hours, mins, seconds strings
        guard let hoursMinsSecsStrs = durationString?.split(separator: ":").map(String.init) else { return nil }
        
        // Then convert from array of strings to array of ints, and calculate the duration in milliseconds
        let hoursMinsSecs = hoursMinsSecsStrs.map { Int($0) ?? 0 }
        let durationInSecs = (hoursMinsSecs[1] * 60) + (hoursMinsSecs[0] * 60 * 60)
        print ("Duration of \(self.subject!): ", TimeInterval(durationInSecs))
        return TimeInterval(durationInSecs)
    }
    var recurrenceType: String?
    var subject: String?
    var category: String?
    var accepted: [TribeMember]?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case owner = "user"
        case recurrenceType = "recurrence_type"
        case to = "to"
        case start = "start"
        case durationString = "duration"
        case subject = "subject"
        case category = "category"
        case accepted = "accepted"
    }
}

struct EventResults: Codable {
    var count: Int?
    var results: [Event]
}
