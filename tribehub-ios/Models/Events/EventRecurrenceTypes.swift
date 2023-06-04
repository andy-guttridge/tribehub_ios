//
//  EventRecurrenceTypes.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 02/06/2023.
//

import Foundation

/// Provides a string value for each recurrence type code recognised by the API
enum EventRecurrenceTypes: String, CaseIterable {
    case NON, DAI, WEK, TWK, MON, YEA, REC
    
    /// Returns  a  string for each event category
    var text: String {
        switch self {
        case .NON: return "None"
        case .DAI: return "Daily"
        case .WEK: return "Weekly"
        case .TWK: return "Fortnightly"
        case .MON: return "Monthly"
        case .YEA: return "Yearly"
        case .REC: return "Recurrence"
        }
    }
}
