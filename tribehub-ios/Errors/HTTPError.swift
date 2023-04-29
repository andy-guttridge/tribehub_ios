//
//  PermissionError.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 21/04/2023.
//

import Foundation

enum HTTPError: Error {
    case badRequest (apiResponse: Codable)
    case noPermission
    case notFound
    case serverError
    case otherError (statusCode: Int)
    case noResponse
}
