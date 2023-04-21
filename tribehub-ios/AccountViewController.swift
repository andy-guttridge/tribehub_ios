//
//  AccountViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 21/04/2023.
//

import UIKit

class AccountViewController: UIViewController {
    weak var userModelController: UserModelController?
    weak var tribeModelController: TribeModelController?

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

  
    @IBAction func didPressLogoutButton(_ sender: Any) {
        guard let userModelController = self.userModelController else {
                    return
                }
                
                Task.init {
                    do {
                        let result = try await userModelController.doLogout()
                        self.dismiss(animated: true)
                    } catch {
                        let alert = UIAlertController(title: "Logout Error", message:"There was an issue logging out.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: {alertAction in alert.dismiss(animated: true)}))
                        self.present(alert, animated: true)
                    }
                }
    }
}
