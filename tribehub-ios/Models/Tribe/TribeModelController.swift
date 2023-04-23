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
                    let profileImageFile: Data = try await tribeRequest.fetchFile(fromURL: imageUrl)
                    self.tribe?.tribeMembers[index].profileImage = UIImage(data: profileImageFile)
                }
            }
        }
        print("Tribe details: ", self.tribe)
    }
}
