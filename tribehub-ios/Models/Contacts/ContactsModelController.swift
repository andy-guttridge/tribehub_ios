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
        let response = try await contactsRequest.fetchData()
        contacts = response
    }
    
    /// Attempts to create a new contact in the API using the provided payload dictionary
    func createContact(
        category: String?,
        company: String?,
        title: String?,
        firstName: String?,
        lastName: String?,
        telNumber: String?,
        email: String?) async throws {
            guard let session = self.session else {
                throw SessionError.noSession
            }
            
            let newContactRequest = APIRequest(resource: ContactsResource(), session: session)
            let payload = [
                "category": category ?? "",
                "company": company ?? "",
                "title": title ?? "",
                "first_name": firstName ?? "",
                "last_name": lastName ?? "",
                "phone": telNumber ?? "",
                "email": email ?? ""
            ]
            _ = try await newContactRequest.postData(payload: payload as Dictionary<String, Any>)
        }
}
