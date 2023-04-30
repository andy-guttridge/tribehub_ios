//
//  UpdateProfileResource.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 30/04/2023.
//

import Foundation

class UpdateProfileResource: APIResource {
    typealias ModelType = GenericAPIResponse
    var methodPath: String {
        return "profile/"
    }
}
