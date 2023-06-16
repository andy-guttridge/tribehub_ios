//
//  NetworkRequest.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 30/03/2023.
//

import Foundation
import Alamofire

// Makes a request to the API using supplied resource and session
class APIRequest<Resource: APIResource> {
    let resource: Resource
    let session: Session
    let decoder: JSONDecoder
    
    init(resource: Resource, session: Session) {
        self.resource = resource
        self.session = session
        
        // Custom JSONDecoder needed for date format supplied by the API.
        // Technique for using a dateDecodingStrategy/encodingStrategy
        // with a DateFormatter matching the API's date format is from
        // https://stackoverflow.com/questions/50847139/error-decoding-date-with-swift
        self.decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .gmt
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
    }
    
    func fetchData (forPk pk: Int? = nil, urlParameters: [String: String]? = nil) async throws -> Resource.ModelType? {
        var url = resource.url
        if let pk = pk {
            url += "\(pk)/"
        }
        let response = await session.request(url, method: .get, parameters: urlParameters).validate().serializingDecodable(Resource.ModelType.self, decoder: decoder).response
        try checkHttpResponseCodeForResponse(response)
        let value = response.value
        return value
    }
    
    func postData (itemForPrimaryKey pk: Int? = nil, payload: Dictionary<String, Any>?) async throws -> Resource.ModelType? {
        var url = resource.url
        if let pk = pk {
            url.append("\(String(pk))/")
        }
        let response = await session.request(url, method: .post, parameters: payload).validate().serializingDecodable(Resource.ModelType.self, emptyResponseCodes: [200, 204, 205]).response
        try checkHttpResponseCodeForResponse(response)
        let value = response.value
        return value
    }
    
    func putData (itemForPrimaryKey pk: Int, payload: Dictionary<String, Any>?) async throws -> Resource.ModelType? {
        let response = await session.request(resource.url + "\(String(pk))/", method: .put, parameters: payload).validate().serializingDecodable(Resource.ModelType.self, emptyResponseCodes: [200, 204, 205]).response
        try checkHttpResponseCodeForResponse(response)
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
        
        try checkHttpResponseCodeForResponse(response)
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
        try checkHttpResponseCodeForResponse(response as! DataResponse<Resource.ModelType, AFError>)
        return response.value ?? GenericAPIResponse(detail: "No detail response from API")
    }
    
    /// Throws errors for unacceptable HTTP response codes
    func checkHttpResponseCodeForResponse (_ response: DataResponse<Resource.ModelType, AFError>) throws {
        if let statusCode = response.response?.statusCode {
            if statusCode > 299 {
                try checkBadRequestForResponse(response)
                throw HTTPError.otherError(statusCode: response.response!.statusCode)
            }
        } else {
            throw HTTPError.noResponse
        }
    }
    
    /// In the case of an HTTP 400 error from the API, extracts error messages from the API response and throws a .badRequest error with a single string value
    /// which the UI can use to inform the user of the error.
    func checkBadRequestForResponse (_ response: DataResponse<Resource.ModelType, AFError>) throws {
        var errorString = ""
        
        // Extract error messages from the API if HTTP code 400 (i.e. we've made a bad request)
        if response.response?.statusCode == 400 {
            
            // Try to extract the error message as a dictionary of keys each with a single string value, and
            // append keys and their values to a single error message string.
            if let data = response.data {
                do {
                    let errorDict = try JSONDecoder().decode(Dictionary<String, String>.self, from:data)
                    for (key, value) in errorDict {
                        errorString.append("\(key): \(value)\n\n")
                    }
                    throw HTTPError.badRequest(apiResponse: errorString)
                    
                // If that didn't work, then we've probably received a dictionary with an array of strings for each key.
                // In that case, try to decode as such, and reduce each array to a single string value and
                // append with the relevant key to our error string.
                } catch DecodingError.typeMismatch {
                    let errorDict = try JSONDecoder().decode(Dictionary<String, Array<String>>.self, from: data)
                    for (key, value) in errorDict {
                        let str = value.reduce("") {(acc, val) in acc + "\(key): \(val)\n\n"}
                        errorString.append(str)
                    }
                    throw HTTPError.badRequest(apiResponse: errorString)
                }
            }
            throw HTTPError.badRequest(apiResponse: "No API response")
        }
    }
}
