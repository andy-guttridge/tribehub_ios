//
//  makeRounded.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 23/04/2023.
//

import Foundation
import UIKit

/// Extend UIImageView to create circular images
extension UIImageView {
    // Technique to make extend UIImageView to make a rounded image is from
    // https://stackoverflow.com/questions/28074679/how-to-set-image-in-circle-in-swift
    
    func makeRounded() {
        print("Making rounded")
        layer.borderWidth = 1
        layer.masksToBounds = false
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = self.frame.height / 2
        clipsToBounds = true
    }
}
