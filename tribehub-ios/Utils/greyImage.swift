//
//  greyImage.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 25/05/2023.
//

import Foundation
import UIKit

// Code for creating a grey scale copy of an image is from
// https://stackoverflow.com/questions/35959378/how-can-i-temporarily-grey-out-my-uiimage-in-swift

/// Returns a grey scale version of the UIImage
extension UIImage {
    var greyImage: UIImage {
        guard let ciImage = CIImage(image: self) else { return self }
        let filterParameters = [ kCIInputColorKey: CIColor.white, kCIInputIntensityKey: 1.0 ] as [String: Any]
        let grayscale = ciImage.applyingFilter("CIColorMonochrome", parameters: filterParameters)
        return UIImage(ciImage: grayscale)
    }
}
