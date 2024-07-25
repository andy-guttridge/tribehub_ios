//
//  APIResource.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 30/03/2023.
//

import Foundation

/// Protocol provides a template for an APIResource, ensuring
/// conforming types can supply a decodable model type and an API endpoint
protocol APIResource {
    associatedtype ModelType: Codable
    var methodPath: String {get}
}

extension APIResource {
    var url: String {
        return "https://api-tribehub.andyguttridge.co.uk/" + methodPath
    }
}
