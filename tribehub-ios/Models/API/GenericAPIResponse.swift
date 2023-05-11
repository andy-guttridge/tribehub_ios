//
//  GenericAPIResponse.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 27/04/2023.
//

import Foundation

protocol APIResponse: Codable {
    var detail: String? { get }
    var nonFieldError: String? {get}
    
    func getString() -> String
}

/// Model for a generic response from the API
struct GenericAPIResponse: APIResponse {
    var detail: String?
    var nonFieldError: String?
    
    enum CodingKeys: String, CodingKey {
        case nonFieldError = "non_field_error"
    }
    
    func getString() -> String {
        var string = ""
        if let detail = self.detail {
            string = string + detail + "\n"
        }
        if let nonFieldError = self.nonFieldError {
            string = string + nonFieldError + "\n"
        }
        return string
    }
}
