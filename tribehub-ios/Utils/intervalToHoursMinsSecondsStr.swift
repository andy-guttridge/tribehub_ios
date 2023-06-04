//
//  secondsToHoursMinsSecondsStr.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 04/06/2023.
//

import Foundation

/// Accepts a TimeInterval and returns a string
/// in the format 'HH:MM:SS', as accepted by the API for an event
/// duration
func intervalToHoursMinsSecondsStr(_ interval: TimeInterval) -> String {
    let intervalAsSeconds = Int(interval.rounded())
    let hoursStr = String(intervalAsSeconds / 3600)
    let minsStr = String((intervalAsSeconds % 3600) / 60)
    let secondsStr = String((intervalAsSeconds % 3600) % 60)
    print("Returning: \(hoursStr):\(minsStr):\(secondsStr)")
    return "\(hoursStr):\(minsStr):\(secondsStr)"
}
