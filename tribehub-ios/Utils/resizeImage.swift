//
//  resizeImage.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 04/05/2023.
//

import Foundation
import UIKit

/// Resizes a UIImage
func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
    // Code to resize an image is from
    // https://stackoverflow.com/questions/31966885/resize-uiimage-to-200x200pt-px
    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
    image.draw(in: CGRectMake(0, 0, newWidth, newHeight))
    guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
    UIGraphicsEndImageContext()
    
    return newImage
}
