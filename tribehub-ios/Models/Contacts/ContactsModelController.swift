//
//  ContactsModelController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 22/06/2023.
//

import Foundation
import Alamofire

/// Controller for Contacts model
class ContactsModelController {
    
    private weak var session: Session?
    private(set) var contacts: ContactResults?
    
    init(withSession session: Session) {
        self.session = session
    }
    
    /// Fetches user's contacts from the API
    func getContacts() async throws {
        guard let session = self.session else {
            throw SessionError.noSession
        }
        
        let contactsRequest = APIRequest(resource: ContactsResource(), session: session)
        
        do {
            let response = try await contactsRequest.fetchData()
            contacts = response
        }
    }
}
