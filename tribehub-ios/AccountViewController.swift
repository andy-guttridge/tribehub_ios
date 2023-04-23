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

    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.profileImageView.image = userModelController?.user?.profileImage
        self.profileImageView.makeRounded()
    }

  
    @IBAction func didPressLogoutButton(_ sender: Any) {
        guard let userModelController = self.userModelController else {
                    return
                }
                
                Task.init {
                    do {
                        _ = try await userModelController.doLogout()
                        self.dismiss(animated: true)
                    } catch {
                        let alert = UIAlertController(title: "Logout Error", message:"There was an issue logging out.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: {alertAction in alert.dismiss(animated: true)}))
                        self.present(alert, animated: true)
                    }
                }
    }
}
