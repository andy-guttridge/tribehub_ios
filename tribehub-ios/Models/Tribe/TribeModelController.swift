//
//  TribeModelController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 21/04/2023.
//

import Foundation
import Alamofire

class TribeModelController {
    private(set) var tribe: Tribe?
    private weak var session: Session?
    private weak var userModelController: UserModelController?
    
    init(withSession session: Session) {
        self.session = session
    }
    
    func getTribe() async throws {
        guard let session = self.session else {
            throw SessionError.noSession
        }
        
        // Try to fetch user's tribe data
        let tribeRequest = APIRequest(resource: TribeResource(), session: session)
        do {
            let response = try await tribeRequest.fetchData()
            self.tribe = response?.results[0]
        } catch HTTPError.noPermission {
            self.userModelController?.userAuthDidExpire()
            return
        }
        
        // Try to fetch tribe profile images
        if let tribe = self.tribe {
            for (index, tribeMember) in tribe.tribeMembers.enumerated() {
                // Try to fetch profile image
                if let imageUrl = tribeMember.profileImageURL {
                    do {
                        let profileImageFile: Data = try await tribeRequest.fetchFile(fromURL: imageUrl)
                        self.tribe?.tribeMembers[index].profileImage = UIImage(data: profileImageFile)
                    } catch {
                        print("Error fetching profile image")
                    }
                }
            }
        }
    }
    
    func doDeleteTribeMember(forPrimaryKey pk: Int) async throws -> GenericAPIResponse? {
        guard let session = self.session else {
            throw SessionError.noSession
        }
        
        // Attempt to delete tribe member from backend
        let deleteTribeMemberAPIRequest = APIRequest(resource: DeleteUserResource(), session: session)
        let response = try await deleteTribeMemberAPIRequest.delete(itemForPrimaryKey: pk)
        
        // If no error thrown, filter out the deleted tribe member from the array of tribe members we hold in this instance
        let newTribe = self.tribe?.tribeMembers.filter {$0.pk != pk}
        if let editedTribe = newTribe {
            self.tribe?.tribeMembers = editedTribe
        }
        return response
    }
    
    func doAddTribeMember(withUserName userName: String, passWord: String) async throws -> GenericAPIResponse? {
        guard let session = self.session else {
            throw SessionError.noSession
        }
        // Attempt to create new tribe member in backend
        let newTribeMemberAPIRequest = APIRequest(resource: AddNewTribeMemberResource(), session: session)
        let response = try await newTribeMemberAPIRequest.postData(payload: ["username": userName, "password": passWord, "password2": passWord])
        
        // If no error thrown, fetch tribe members again so new one is included with the correct pk
        try await self.getTribe()
        return response
    }
}
