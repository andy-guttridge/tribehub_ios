//
//  ContactsNavigationController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 22/06/2023.
//

import UIKit

class ContactsNavigationController: UINavigationController {
    
    weak var contactsModelController: ContactsModelController?
    weak var userModelController: UserModelController?

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        

        // Do any additional setup after loading the view.
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

// MARK: private extension
private extension ContactsNavigationController {
    func initialize() {
        if let contactDetailsTableViewController = viewControllers.first as? ContactDetailsTableViewController {
            contactDetailsTableViewController.contactsModelController = contactsModelController
            contactDetailsTableViewController.userModelController = userModelController
        }
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = UIColor(named: "THBackground")
        navigationBar.tintColor = UIColor(named: "THIcons")
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Fredoka-Bold", size: 20)!]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Nunito-SemiBold", size: 18)!], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Nunito-SemiBold", size: 18)!], for: .highlighted)
    }
}
