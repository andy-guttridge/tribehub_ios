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
    weak var eventsModelController: EventsModelController?
    
    private var cancellable: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        cancellable = userModelController?.$user.sink { [weak self] user in self?.userStatusDidChange(user)}
        if let accountNavigationController = self.viewControllers?.last as? AccountNavigationController {
                    accountNavigationController.userModelController = userModelController
                    accountNavigationController.tribeModelController = tribeModelController
                } else {
                    print("No accountNavigationViewController!")
                }
        if let homeNavigationController = self.viewControllers?.first as? HomeNavigationController {
            homeNavigationController.eventsModelController = eventsModelController
            homeNavigationController.userModelController = userModelController
            homeNavigationController.tribeModelController = tribeModelController
        } else {
            print("No homeNavigationViewController!")
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
            loginViewController.userModelController = userModelController
            loginViewController.tribeModelController = tribeModelController
        }
    }
    
    private func userStatusDidChange(_ user: User?) {
        if user == nil {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "loginSegue", sender: self)
            }
        }
    }
}

extension TabBarViewController: LoginViewControllerDelegate {
    func dismissLoginModal() {
        dismiss(animated: true)
    }
}
