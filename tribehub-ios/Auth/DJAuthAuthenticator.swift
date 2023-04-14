//
//  DJAuthAuthenticator.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 13/04/2023.
//

import Foundation
import Alamofire

class DJAuthAuthenticator: Authenticator {
    func apply(_ credential: DJAuthCredential, to urlRequest: inout URLRequest) {
        guard let accessToken = credential.accessToken else {
            print("Could not get access token in DJAuthAuthenticator")
            return
        }
        print("Expiration: ", credential.expiration)
        // Commented out, as don't actually need an authorization header as using  cookies
        // urlRequest.headers.add(.authorization(bearerToken: accessToken))
    }
    
    func refresh (_ credential: DJAuthCredential, for session: Session, completion: @escaping (Result<DJAuthCredential, Error>) -> Void) {
        Task.init {
            // Get the refresh  token from the credential
            let refreshToken = RefreshToken(refresh: credential.refreshToken ?? "nil_refresh")
            // Call the refresh end point
            let result = try await session.request("https://tribehub-drf.herokuapp.com/dj-rest-auth/token/refresh/", method: .post, parameters: refreshToken).serializingDecodable(AccessToken.self).result
            //Convert the returned credential to a DJAuthCredential
            let aCredential = result.map {accessToken in
                let newCred = DJAuthCredential(accessToken: accessToken.access, refreshToken: refreshToken.refresh)
                return newCred
            }
            // And convert the AFError to a generice Error
            let newCredential = aCredential.mapError {error in
                return error as Error
            }
            
            // Maybe  try changing the type of the credential that conforms to AuthenticationCredential so it is the same as AccessToken,. We would not then have to pull out the access token separately in the apply method above.
            
            // Remember to try changing the refresh timer back to 4 minutes when this is all working properly
            
            // The value of the refresh token needs to be updated somehow (when we have proper persistent user state)
            // and the completion handler needs to be called
            completion(newCredential)
        }
    }
    
    func didRequest(_ urlRequest: URLRequest, with response: HTTPURLResponse, failDueToAuthenticationError error: Error) -> Bool {
        return false
    }
    
    func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: DJAuthCredential) -> Bool {
        return true
    }
}
