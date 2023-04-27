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
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
