//
//  addSpinnerViewtoView.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 17/06/2023.
//

import Foundation
import UIKit

// Code for creating and removing a SpinnerViewController adapated from
// https://www.hackingwithswift.com/example-code/uikit/how-to-use-uiactivityindicatorview-to-show-a-spinner-when-work-is-happening

/// Creates a spinnerViewController and adds it and its view as a child of the specified viewController
func addSpinnerViewTo(_ viewController: UIViewController) -> SpinnerViewController {
    let spinnerViewController = SpinnerViewController()
    
    viewController.addChild(spinnerViewController)
    spinnerViewController.view.frame = viewController.view.frame
    viewController.view.addSubview(spinnerViewController.view)
    viewController.didMove(toParent: viewController)
    return spinnerViewController
}

/// Removes the specifies spinnerViewController and its view from its parent
func removeSpinnerView(_ spinnerViewController: SpinnerViewController) {
    spinnerViewController.willMove(toParent: nil)
    spinnerViewController.view?.removeFromSuperview()
    spinnerViewController.removeFromParent()
}
