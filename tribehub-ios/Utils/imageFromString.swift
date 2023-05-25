//
//  makeImage.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 25/05/2023.
//

import Foundation
import UIKit

// Code to generate an image from a string is from
// https://stackoverflow.com/questions/51100121/how-to-generate-an-uiimage-from-custom-text-in-swift

/// Creates an image from the given string
func imageFromString(_ str: String, width: Int, height: Int) -> UIImage? {
    let frame = CGRect(x:0, y:0, width: width, height: height)
    
    // Create and configure a UILabel with the given text
    let textLabel = UILabel(frame: frame)
    textLabel.textAlignment = .center
    textLabel.backgroundColor = .systemIndigo
    textLabel.textColor = .white
    textLabel.font = UIFont.boldSystemFont(ofSize: 250)
    textLabel.text = str
    
    // Create a graphics context and render the label as an image
    UIGraphicsBeginImageContext(frame.size)
    if let currentContext = UIGraphicsGetCurrentContext() {
        textLabel.layer.render(in: currentContext)
        let textImage = UIGraphicsGetImageFromCurrentImageContext()
        return textImage
    }
    return nil
}
