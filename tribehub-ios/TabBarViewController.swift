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
        Task.init {
            cancellable = await userModelController?.$user.sink { [weak self] user in self?.userStatusDidChange(user)}
        }
        if let accountNavigationController = self.viewControllers?.last as? AccountNavigationController {
                    accountNavigationController.userModelController = userModelController
                    accountNavigationController.tribeModelController = tribeModelController
                } else {
                    print("No accountNaviigationViewController!")
                }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        var user: User?
        Task.init {
            user = await self.userModelController?.user
            await print("User status in tabBarController: ", user)
            if user == nil {
                performSegue(withIdentifier: "loginSegue", sender: self)
            }
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
