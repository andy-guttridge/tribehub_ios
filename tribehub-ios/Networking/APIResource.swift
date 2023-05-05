//
//  APIResource.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 30/03/2023.
//

import Foundation

protocol APIResource {
    associatedtype ModelType: Codable
    var methodPath: String {get}
}

extension APIResource {
    var url: String {
        return "https://tribehub-drf.herokuapp.com/" + methodPath
        // return "http://127.0.0.1:8000/" + methodPath
    }
}
