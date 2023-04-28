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
        let response = await session.request(resource.url, method: .get).validate().serializingDecodable(Resource.ModelType.self).response
        switch response.result {
        case .success:
            print("Fetched resource")
        case .failure (let error):
            throw error
        }
        let value = response.value
        print (value)
        return value
    }
    
    func postData (payload: Dictionary<String, Any>?) async throws -> Resource.ModelType? {
        let response = await session.request(resource.url, method: .post, parameters: payload).validate().serializingDecodable(Resource.ModelType.self, emptyResponseCodes: [200, 204, 205]).response
        switch response.result {
        case .success:
            print("Posted resource")
        case .failure (let error):
            throw error
        }
        let value = response.value
        print (value)
        return value
    }
    
    func fetchFile<FileType> (fromURL urlString: String) async throws -> FileType {
        let url = URL(string:  urlString)
        guard let urlConvertible = try url?.asURL() else {
            throw AFError.invalidURL(url: urlString)
        }
        let file: FileType = try await AF.download(urlConvertible).serializingData().value as! FileType
        return file
    }
    
    func delete(itemForPrimaryKey pk: Int) async throws -> GenericAPIResponse {
        let url = resource.url + "\(String(pk))/"
        let response = await session.request(url, method: .delete).validate().serializingDecodable(GenericAPIResponse.self).response
        switch response.result {
        case .success:
            print("Deleted resource")
        case .failure (let error):
            throw error
        }
        let value = response.value
        return value ?? GenericAPIResponse(detail: "none")
    }
}
