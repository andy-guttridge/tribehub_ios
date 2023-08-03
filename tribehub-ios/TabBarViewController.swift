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
    weak var contactsModelController: ContactsModelController?
    
    private var cancellable: AnyCancellable?
    
    // Use this to tell if the app has just been launched
    private var justLaunched = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancellable = userModelController?.$user.sink { [weak self] user in self?.userStatusDidChange(user)}
        if let accountNavigationController = self.viewControllers?.last as? AccountNavigationController {
                    accountNavigationController.userModelController = userModelController
                    accountNavigationController.tribeModelController = tribeModelController
                } else {
                    print("No accountNavigationController!")
                }
        
        if let homeNavigationController = self.viewControllers?.first as? HomeNavigationController {
            homeNavigationController.eventsModelController = eventsModelController
            homeNavigationController.userModelController = userModelController
            homeNavigationController.tribeModelController = tribeModelController
        } else {
            print("No homeNavigationController!")
        }
        
        if let contactsNavigationController = viewControllers?[1] as? ContactsNavigationController {
            contactsNavigationController.contactsModelController = contactsModelController
            contactsNavigationController.userModelController = userModelController
        } else {
            print("No contactsNavigationController!")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        // Show login screen if user is not already logged in and
        // app has just been launched
        if self.userModelController?.user == nil && justLaunched == true {
            performSegue(withIdentifier: "loginSegue", sender: self)
            justLaunched = false
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
                // Don't show loginViewController if app has just launched, otherwise
                // we end up showing the login view before the app is ready, generating
                // console warnings
                if self.justLaunched == false {
                    self.performSegue(withIdentifier: "loginSegue", sender: self)
                }
            }
        }
    }
}

extension TabBarViewController: LoginViewControllerDelegate {
    func dismissLoginModal() {
        dismiss(animated: true)
    }
}
