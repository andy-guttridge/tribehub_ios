//
//  DJAuthAuthenticator.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 13/04/2023.
//

import Foundation
import Alamofire

// Requests a refresh token from the API and then retries requests in the event an HTTP status code of 401 is returned.
// Does not retry more than two times
class RefreshRequestRetrier: RequestRetrier {
    func retry(_ request: Alamofire.Request, for session: Alamofire.Session, dueTo error: Error, completion: @escaping (Alamofire.RetryResult) -> Void) {
        
        // Retry request if the previous request returned a 401 error, and don't retry if retryCount is > 2
        // If retrying, firstly call the refresh API endpoint, then completion handler to retry. Otherwise, the request has failed.
        Task.init {
            if request.response?.statusCode == 401 && request.retryCount < 2 {
                let result = await session.request("https://tribehub-drf.herokuapp.com/dj-rest-auth/token/refresh/", method: .post).serializingDecodable(AccessToken.self).result
                switch result {
                case .success(_):
                    completion(.retry)
                case .failure(_):
                    completion(.doNotRetry)
                }
            }
            else {
                completion(.doNotRetry)
            }
        }
    }
}
