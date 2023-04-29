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
        let response = await session.request(resource.url, method: .get).serializingDecodable(Resource.ModelType.self).response
        guard let statusCode = response.response?.statusCode else {
            throw HTTPError.noResponse
        }
        switch statusCode {
            case 200..<300:
                // Success - value returned below
                break
            case 400:
                throw HTTPError.badRequest(apiResponse: response.value)
            case 401:
                throw HTTPError.noPermission
            case 404:
                throw HTTPError.notFound
            case 500:
                throw HTTPError.serverError
            default:
                throw HTTPError.otherError(statusCode: statusCode)
        }
        let value = response.value
        print ("Returning value from fetchData: ", value)
        return value
    }

    func postData (payload: Dictionary<String, Any>?) async throws -> Resource.ModelType? {
        let response = await session.request(resource.url, method: .post, parameters: payload).serializingDecodable(Resource.ModelType.self, emptyResponseCodes: [200, 204, 205]).response
        guard let statusCode = response.response?.statusCode else {
            throw HTTPError.noResponse
        }
        switch statusCode {
            case 200..<300:
                // Success - value returned below
                break
            case 400:
                throw HTTPError.badRequest(apiResponse: response.value)
            case 401:
                throw HTTPError.noPermission
            case 404:
                throw HTTPError.notFound
            case 500:
                throw HTTPError.serverError
            default:
                throw HTTPError.otherError(statusCode: statusCode)
            }
        let value = response.value
        print ("Returning value from postData: ", value)
        return value
    }

    func fetchFile<FileType> (fromURL urlString: String) async throws -> FileType {
        let url = URL(string:  urlString)
        guard let urlConvertible = try url?.asURL() else {
            throw AFError.invalidURL(url: urlString)
        }
        let response = await AF.download(urlConvertible).serializingData().response
        guard let statusCode = response.response?.statusCode else {
            throw HTTPError.noResponse
        }
        switch statusCode {
            case 200..<300:
                // Success - value returned below
                break
            case 400:
                throw HTTPError.badRequest(apiResponse: response.value)
            case 401:
                throw HTTPError.noPermission
            case 404:
                throw HTTPError.notFound
            case 500:
                throw HTTPError.serverError
            default:
                throw HTTPError.otherError(statusCode: statusCode)
        }
        let file: FileType = response.value as! FileType
        return file
    }

    func delete(itemForPrimaryKey pk: Int) async throws -> GenericAPIResponse {
        let url = resource.url + "\(String(pk))/"
        let response = await session.request(url, method: .delete).validate().serializingDecodable(GenericAPIResponse.self).response
        guard let statusCode = response.response?.statusCode else {
            throw HTTPError.noResponse
        }
        switch statusCode {
            case 200..<300:
                // Success - value returned below
                break
            case 400:
                throw HTTPError.badRequest(apiResponse: response.value)
            case 401:
                throw HTTPError.noPermission
            case 404:
                throw HTTPError.notFound
            case 500:
                throw HTTPError.serverError
            default:
                throw HTTPError.otherError(statusCode: statusCode)
        }
        let value = response.value
        return value ?? GenericAPIResponse(detail: "No detail response from API")
    }
}
