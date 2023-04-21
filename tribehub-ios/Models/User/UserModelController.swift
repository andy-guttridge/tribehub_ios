//
//  UserModelController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 20/04/2023.
//

import Foundation
import Alamofire

class UserModelController: ObservableObject {
    @Published private(set) var user: User?
    private weak var session: Session?
    
    init(withSession session: Session) {
        self.session = session
    }
    
    func doLogin(userName: String, passWord: String) async throws -> User? {
        guard let session = self.session else {
            throw SessionError.noSession
        }
        let loginRequest = APIRequest(resource: LoginResource(), session: session)
        let response = try await loginRequest.postData(payload: ["username": userName, "password": passWord])
        self.user = response?.user
        return response?.user
    }
    
    func doLogout() async throws -> AuthResponse? {
        guard let session = self.session else {
            throw SessionError.noSession
        }
        let logoutRequest = APIRequest(resource: LogoutResource(), session: session)
        let response = try await logoutRequest.postData(payload: nil)
        print("Logged out successfully")
        self.user = nil
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        return response
    }
}
