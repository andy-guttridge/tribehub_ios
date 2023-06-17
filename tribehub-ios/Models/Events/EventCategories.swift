//
//  EventCategories.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 18/05/2023.
//

import Foundation
import UIKit

/// Provides an icon image and string title for each of the event category codes returned and accepted by the API
enum EventCategories: String, CaseIterable {
    case CEL, CLU, EDU, MED, MUS, OUT, OTH, PET, SHO, SPO, VAC, WOR, NON
    
    /// Returns an svg icon for each event category
    var image: UIImage {
        switch self {
        case .CEL: return UIImage(named: "present") ?? UIImage()
        case .CLU: return UIImage(named: "club") ?? UIImage()
        case .EDU: return UIImage(named: "education") ?? UIImage()
        case .MED: return UIImage(named: "medical") ?? UIImage()
        case .MUS: return UIImage(named: "music") ?? UIImage()
        case .OUT: return UIImage(named: "car") ?? UIImage()
        case .OTH: return UIImage(named: "other") ?? UIImage()
        case .PET: return UIImage(named: "pets") ?? UIImage()
        case .SHO: return UIImage(named: "shopping") ?? UIImage()
        case .SPO: return UIImage(named: "sport") ?? UIImage()
        case .VAC: return UIImage(named: "vacation") ?? UIImage()
        case .WOR: return UIImage(named: "work") ?? UIImage()
        case .NON: return UIImage(named: "none") ?? UIImage()
        }
    }
    
    /// Returns  a  string for each event category
    var text: String {
        switch self {
        case .CEL: return "Celebration"
        case .CLU: return "Club"
        case .EDU: return "Education"
        case .MED: return "Medical"
        case .MUS: return "Music"
        case .OUT: return "Outing"
        case .OTH: return "Other"
        case .PET: return "Pets"
        case .SHO: return "Shopping"
        case .SPO: return "Sport"
        case .VAC: return "Vacation"
        case .WOR: return "Work"
        case .NON: return "None"
        }
    }
}
