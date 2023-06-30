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
    
    /// Fetches user's contacts from the API. Accepts optional search ter
    func getContacts(searchTerm: String? = nil) async throws {
        guard let session = self.session else {
            throw SessionError.noSession
        }
        
        var urlParameter: [String: String]?
        
        if let searchTerm = searchTerm {
            urlParameter = ["search": searchTerm]
        }
        
        let contactsRequest = APIRequest(resource: ContactsResource(), session: session)
        let response = try await contactsRequest.fetchData(urlParameters: urlParameter)
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
    
    /// Attempts to edit a contact in the API using the provided payload dictionary
    func editContactForPk(
        _ pk: Int,
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
            _ = try await newContactRequest.putData(itemForPrimaryKey: pk, payload: payload)
        }
    
    func deleteContactForPk(_ pk: Int) async throws {
        guard let session = session else {
            throw SessionError.noSession
        }
        
        let deleteContactRequest = APIRequest(resource: DeleteContactResource(), session: session)
        _ = try await deleteContactRequest.delete(itemForPrimaryKey: pk)
        // If no error thrown, filter out the deleted contact from the array of contacts we hold in this instance
        let newContacts = self.contacts?.results.filter {$0.id != pk}
        if let editedContacts = newContacts {
            self.contacts?.results = editedContacts
            self.contacts?.count? -= 1
        }
    }
}
