//
//  TribeResource.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 30/03/2023.
//

import Foundation
import Alamofire

// Resource supplies decodable model and API endpoint for user's tribe details
class TribeResource: APIResource {
    typealias ModelType = TribeResults
    var methodPath: String {
        return "tribe/"
    }
}
