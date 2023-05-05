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
    weak var tribeModelController: TribeModelController?
    
    init(withSession session: Session) {
        self.session = session
    }
    
    func doLogin(userName: String, passWord: String) async throws -> User? {
        guard let session = self.session else {
            throw SessionError.noSession
        }
        // Try to login and if successful fetch user details from API
        let loginRequest = APIRequest(resource: LoginResource(), session: session)
        let response = try await loginRequest.postData(payload: ["username": userName, "password": passWord])
        self.user = response?.user
        
        // Try to fetch profile image
        if let imageUrl = user?.profileImageURL {
            do {
                let profileImageFile: Data = try await loginRequest.fetchFile(fromURL: imageUrl)
                self.user?.profileImage = UIImage(data: profileImageFile)
            } catch {
                print("Error fetching profile image")
            }
        }
        return response?.user
    }
    
    func doLogout() async throws -> AuthResponse? {
        guard let session = self.session else {
            throw SessionError.noSession
        }
        let logoutRequest = APIRequest(resource: LogoutResource(), session: session)
        let response = try await logoutRequest.postData(payload: nil)
        self.user = nil
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        return response
    }
    
    func doDeleteUser(forPrimaryKey pk: Int, isDeletingOwnAccount: Bool = false) async throws -> GenericAPIResponse? {
        guard let session = self.session else {
            throw SessionError.noSession
        }
        let deleteUserAPIRequest = APIRequest(resource: DeleteUserResource(), session: session)
        let response = try await deleteUserAPIRequest.delete(itemForPrimaryKey: pk)
        if isDeletingOwnAccount {
            self.user = nil
        }
        return response
    }
    
    func doUpdateDisplayName(_ name: String, forPrimaryKey pk: Int) async throws -> GenericAPIResponse? {
        guard let session = self.session else {
            throw SessionError.noSession
        }
        let updateProfileAPIRequest = APIRequest(resource: UpdateProfileResource(), session: session)
        let payload = ["display_name": name]
        let response = try await updateProfileAPIRequest.putData(itemForPrimaryKey: pk, payload: payload)
        
        // Update display name in current user instance if payload contains a displayName
        self.user?.displayName = name
        
        // Tell the tribeModelController that this user's display name has changed
        self.tribeModelController?.updateTribeMemberDetails(displayName: name, profileImage: nil, forTribeMemberWithPk: pk)
        return response
    }
    
    func doUpdatePassword(forPrimaryKey pk: Int, newPassword: String, oldPassword: String) async throws -> GenericAPIResponse? {
        guard let session = self.session else {
            throw SessionError.noSession
        }
        let payload = ["new_password1": newPassword, "new_password2": newPassword, "old_password": oldPassword]
        let updatePasswordAPIRequest = APIRequest(resource: UpdatePasswordResource(), session: session)
        let response = try await updatePasswordAPIRequest.postData(payload: payload)
        return response
    }
    
    func doUpdateProfileImage(forPrimaryKey pk: Int, image: UIImage) async throws -> GenericAPIResponse? {
        guard let session = self.session else {
            throw SessionError.noSession
        }
        guard let tribeModelController = self.tribeModelController else {
            return nil
        }
        let uploadProfileImageAPIRequest = APIRequest(resource: UpdateProfileResource(), session: session)
        let response = try await uploadProfileImageAPIRequest.putProfileImageData(forPrimaryKey: pk, image: image, displayName: self.user?.displayName ?? "")
        self.user?.profileImage = image
        
        // Ask the tribeModelController to update the profile image for this member of the tribe
        tribeModelController.updateTribeMemberDetails(displayName: nil, profileImage: image, forTribeMemberWithPk: pk)
        return response
    }
    
    func userAuthDidExpire() {
        self.user = nil
    }
}
