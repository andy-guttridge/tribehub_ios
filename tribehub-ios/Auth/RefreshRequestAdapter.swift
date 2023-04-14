//
//  RefreshRequestAdapter.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 14/04/2023.
//

import Foundation
import Alamofire

class RefreshRequestAdapter: RequestAdapter {
    // RequestAdapter doesn't actually do anything except call the completion handler with the urlRequest,
    // but the interceptor with the RequestRetrier also needs a RequestAdapter.
    func adapt(_ urlRequest: URLRequest, for session: Alamofire.Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        completion(.success(urlRequest))
    }
}
