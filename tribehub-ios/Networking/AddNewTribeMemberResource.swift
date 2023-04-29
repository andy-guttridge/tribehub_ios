//
//  AddNewTribeMemberResource.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 28/04/2023.
//

import Foundation

class AddNewTribeMemberResource: APIResource {
    typealias ModelType = GenericAPIResponse
    var methodPath: String {
        return "accounts/user/"
    }
}
