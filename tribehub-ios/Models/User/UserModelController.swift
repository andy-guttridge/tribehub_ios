//
//  UserModelController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 20/04/2023.
//

import Foundation
import Alamofire

class UserModelController {
    private(set) var user: User?
    private var session: Session
    
    init(withSession session: Session) {
        self.session = session
    }
    
    func doLogin(userName: String, passWord: String) async throws -> User? {
        let loginRequest = APIRequest(resource: LoginResource(), session: self.session)
        let response = try await loginRequest.postData(payload: ["username": userName, "password": passWord])
        self.user = response?.user
        return response?.user
    }
}
