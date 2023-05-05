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
        if response.response?.statusCode == 400 {
            if let data = response.data {
                do {
                    let errorDict = try JSONDecoder().decode(Dictionary<String, String>.self, from:data)
                    throw HTTPError.badRequest(apiResponse: errorDict)
                } catch DecodingError.typeMismatch {
                    let errorDict = try JSONDecoder().decode(Dictionary<String, Array<String>>.self, from: data)
                    if let strings = errorDict.values.first?.reduce("", {acc, str in acc + str + "\n\n"}) {
                        throw HTTPError.badRequest(apiResponse: ["API Error": strings])
                    }
                }
            }
            throw HTTPError.badRequest(apiResponse: ["detail": "No API response"])
        }
        let value = response.value
        return value
    }
    
    func postData (payload: Dictionary<String, Any>?) async throws -> Resource.ModelType? {
        let response = await session.request(resource.url, method: .post, parameters: payload).validate().serializingDecodable(Resource.ModelType.self, emptyResponseCodes: [200, 204, 205]).response
        if response.response?.statusCode == 400 {
            if let data = response.data {
                do {
                    let errorDict = try JSONDecoder().decode(Dictionary<String, String>.self, from:data)
                    throw HTTPError.badRequest(apiResponse: errorDict)
                } catch DecodingError.typeMismatch {
                    let errorDict = try JSONDecoder().decode(Dictionary<String, Array<String>>.self, from: data)
                    if let strings = errorDict.values.first?.reduce("", {acc, str in acc + str + "\n\n"}) {
                        throw HTTPError.badRequest(apiResponse: ["API Error": strings])
                    }
                }
            }
            throw HTTPError.badRequest(apiResponse: ["detail": "No API response"])
        }
        let value = response.value
        return value
    }
    
    func putData (itemForPrimaryKey pk: Int, payload: Dictionary<String, Any>?) async throws -> Resource.ModelType? {
        let response = await session.request(resource.url + "\(String(pk))/", method: .put, parameters: payload).validate().serializingDecodable(Resource.ModelType.self, emptyResponseCodes: [200, 204, 205]).response
        if response.response?.statusCode == 400 {
            if let data = response.data {
                do {
                    // Try to extract straightfoward dictionary with error strings
                    let errorDict = try JSONDecoder().decode(Dictionary<String, String>.self, from:data)
                    throw HTTPError.badRequest(apiResponse: errorDict)
                } catch DecodingError.typeMismatch {
                    // If that fails, try to extract a dictionary with arrays of error strings, as the API
                    // sometimes returns these. Extract all strings from each array, and return as one long string with line breaks.
                    let errorDict = try JSONDecoder().decode(Dictionary<String, Array<String>>.self, from: data)
                    var strings = ""
                    for (key, _) in errorDict {
                        if let string = errorDict[key]?.reduce("", {acc, str in acc + str + "\n\n"}) {
                            strings.append(string)
                        }
                        throw HTTPError.badRequest(apiResponse: ["API Error": strings])
                    }
                }
            }
            throw HTTPError.badRequest(apiResponse: ["detail": "No API response"])
        }
        let value = response.value
        return value
    }
    
    // This function is not currently generic/re-usable enough. Aim to refactor into a more general purpose form data upload function.
    func putProfileImageData (forPrimaryKey pk: Int, image: UIImage, displayName: String) async throws -> Resource.ModelType? {
        let url: String? = resource.url + "\(String(pk))/"
        guard let urlConvertible = try url?.asURL() else {
            throw AFError.invalidURL(url: url ?? "")
        }
        // Resize if image too big
        var theImage = image
        if image.size.width > 500 || image.size.height > 500 {
            theImage = resizeImage(image: image, newWidth: 500)
        }
        
        // Upload as multipart form data. Set filename to 'image' for the benefit of the API, cloudinary renames it anyway.
        let response = await session.upload(multipartFormData: {multiPartFormData in
            multiPartFormData.append(Data(theImage.jpegData(compressionQuality: 1)!), withName: "image", fileName: "profile_image.jpeg", mimeType: "image/jpeg")
            multiPartFormData.append(Data(displayName.utf8), withName: "display_name")
            },
            to: urlConvertible, method: .put).validate().serializingDecodable(Resource.ModelType.self, emptyResponseCodes: [200, 204, 205]).response
        
        // Manually throw errors as AF doesn't validate the multi-part form upload request
        if let statusCode = response.response?.statusCode {
            if statusCode > 299 {
                if statusCode == 400 {
                    if let data = response.data {
                        do {
                            let errorDict = try JSONDecoder().decode(Dictionary<String, String>.self, from:data)
                            throw HTTPError.badRequest(apiResponse: errorDict)
                        } catch DecodingError.typeMismatch {
                            let errorDict = try JSONDecoder().decode(Dictionary<String, Array<String>>.self, from: data)
                            if let strings = errorDict.values.first?.reduce("", {acc, str in acc + str + "\n\n"}) {
                                throw HTTPError.badRequest(apiResponse: ["API Error": strings])
                            }
                        }
                    }
                } else {
                    throw HTTPError.otherError(statusCode: response.response!.statusCode)
                }
            }
        } else {
            throw HTTPError.noResponse
        }
        return response.value
    }
        
    
    func fetchFile<FileType> (fromURL urlString: String) async throws -> FileType {
        let url = URL(string:  urlString)
        guard let urlConvertible = try url?.asURL() else {
            throw AFError.invalidURL(url: urlString)
        }
        let file: FileType = try await session.download(urlConvertible).serializingData().value as! FileType
        return file
    }
    
    func delete(itemForPrimaryKey pk: Int) async throws -> GenericAPIResponse {
        let url = resource.url + "\(String(pk))/"
        let response = await session.request(url, method: .delete).validate().serializingDecodable(GenericAPIResponse.self).response
        if response.response?.statusCode == 400 {
            if let data = response.data {
                do {
                    let errorDict = try JSONDecoder().decode(Dictionary<String, String>.self, from:data)
                    throw HTTPError.badRequest(apiResponse: errorDict)
                } catch DecodingError.typeMismatch {
                    let errorDict = try JSONDecoder().decode(Dictionary<String, Array<String>>.self, from: data)
                    if let strings = errorDict.values.first?.reduce("", {acc, str in acc + str + "\n\n"}) {
                        throw HTTPError.badRequest(apiResponse: ["detail": strings])
                    }
                }
            }
            throw HTTPError.badRequest(apiResponse: ["detail": "No API response"])
        }
        let value = response.value
        return value ?? GenericAPIResponse(detail: "No detail response from API")
    }
}
