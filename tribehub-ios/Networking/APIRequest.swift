//
//  NetworkRequest.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 30/03/2023.
//

import Foundation
import Alamofire

class APIRequest<Resource: APIResource> {
    let resource: Resource
    let session: Session
    
    init(resource: Resource, session: Session) {
        self.resource = resource
        self.session = session
    }
    
    func fetchData () async throws ->  Resource.ModelType? {
        let value = try await session.request(resource.url, method: .get).serializingDecodable(Resource.ModelType.self).value
        return value
    }
    
    func postData (payload: Dictionary<String, Any>?) async throws -> Resource.ModelType? {
        let response = try await session.request(resource.url, method: .post, parameters: payload).serializingDecodable(Resource.ModelType.self, emptyResponseCodes: [200, 204, 205]).value
        return response
    }
}
