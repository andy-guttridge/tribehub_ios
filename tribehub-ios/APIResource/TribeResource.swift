//
//  TribeResource.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 30/03/2023.
//

import Foundation
import Alamofire

class TribeResource: APIResource {
    typealias APIResponseType = Empty
    typealias ModelType = TribeResults
    var methodPath: String {
        return "tribe/"
    }
}
