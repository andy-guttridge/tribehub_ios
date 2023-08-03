//
//  UserModelController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 20/04/2023.
//

import Foundation
import Alamofire

/// Model controller for UserModel. Retains a reference to the user's details as supplied by the API which is utilised by various other classes.
class UserModelController: ObservableObject {
    
    // Use combine to publish the user property so that other classes can respond to changes in user status.
    // Details on how to use published properties with UIKit are from
    // https://www.swiftbysundell.com/articles/published-properties-in-swift/
    @Published private(set) var user: User?
    private weak var session: Session?
    weak var tribeModelController: TribeModelController?
    
    init(withSession session: Session) {
        self.session = session
    }
    
    /// Attempts to log the user in on the backend using the supplied username and password, and if successful
    /// returns an instance of a User
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
    
    // Attempts to log the user out of the backend and if successful clears cookies
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
    
    /// Attempts to delete the user account for the supplied primary key. Needs to know if the user is deleting their own account
    /// or that of a tribe member in order to clear authenticated user data or not.
    func doDeleteUser(forPrimaryKey pk: Int, isDeletingOwnAccount: Bool = false) async throws -> GenericAPIResponse? {
        guard let session = self.session else {
            throw SessionError.noSession
        }
        let deleteUserAPIRequest = APIRequest(resource: DeleteUserResource(), session: session)
        let response = try await deleteUserAPIRequest.delete(itemForPrimaryKey: pk)
        if isDeletingOwnAccount {
            print("setting user to nil")
            self.user = nil
            HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        }
        return response
    }
    
    /// Attempts to update the user's displayname in the backend.
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
    
    /// Attempts to update the password for the user with the supplied primary key and new and old password details
    func doUpdatePassword(forPrimaryKey pk: Int, newPassword: String, oldPassword: String) async throws -> GenericAPIResponse? {
        guard let session = self.session else {
            throw SessionError.noSession
        }
        let payload = ["new_password1": newPassword, "new_password2": newPassword, "old_password": oldPassword]
        let updatePasswordAPIRequest = APIRequest(resource: UpdatePasswordResource(), session: session)
        let response = try await updatePasswordAPIRequest.postData(payload: payload)
        return response
    }
    
    /// Attempts to update the profile image for the user with the supplied primary key and using the supplied UIImage
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
    
    /// Clears authenticated user's details. Used in the event authentication has expired.
    func userAuthDidExpire() {
        self.user = nil
    }
}
