//
//  AccountNavigationController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 27/04/2023.
//

import UIKit

class AccountNavigationController: UINavigationController {
    weak var userModelController: UserModelController?
    weak var tribeModelController: TribeModelController?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let accountViewController = self.viewControllers[0] as? AccountViewController {
            accountViewController.userModelController = self.userModelController
            accountViewController.tribeModelController = self.tribeModelController
            
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.backgroundColor = UIColor(named: "THBackground")
            navigationBar.tintColor = UIColor(named: "THIcons")
            navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Fredoka-Bold", size: 20)!]
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Nunito-SemiBold", size: 18)!], for: .normal)
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Nunito-SemiBold", size: 18)!], for: .highlighted)
        }
    }
}

