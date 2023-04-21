//
//  TabBarViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 21/04/2023.
//

import UIKit
import Combine
import Alamofire

class TabBarViewController: UITabBarController {
    
    weak var userModelController: UserModelController?
    weak var tribeModelController: TribeModelController?
    
    private var cancellable: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        cancellable = userModelController?.$user.sink { [weak self] user in self?.userStatusDidChange(user)}
        if let accountViewController = self.viewControllers?.last as? AccountViewController {
            accountViewController.userModelController = userModelController
            accountViewController.tribeModelController = tribeModelController
        } else {
            print("No accountViewController!")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if self.userModelController?.user == nil {
            performSegue(withIdentifier: "loginSegue", sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let loginViewController = segue.destination as? LoginViewController {
            loginViewController.delegate = self
            loginViewController.userModelController = self.userModelController
            loginViewController.tribeModelController = self.tribeModelController
        }
    }
    
    private func userStatusDidChange(_ user: User?) {
        if user == nil {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "loginSegue", sender: self)
            }
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

extension TabBarViewController: LoginViewControllerDelegate {
    func dismissLoginModal() {
        dismiss(animated: true)
    }
}
