//
//  ContactsResource.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 22/06/2023.
//

import Foundation

/// Resource supplies decodable model and API endpoint for user's contacts
class ContactsResource: APIResource {
    typealias ModelType = ContactResults
    var methodPath: String {
        return "contacts/"
    }
}
