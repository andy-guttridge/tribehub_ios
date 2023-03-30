//
//  APIResource.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 30/03/2023.
//

import Foundation

protocol APIResource {
    associatedtype ModelType: Codable
    associatedtype APIResponseType: Codable
    var methodPath: String {get}
}

extension APIResource {
    var url: String {
        return "https://tribehub-drf.herokuapp.com/" + methodPath
    }
}
