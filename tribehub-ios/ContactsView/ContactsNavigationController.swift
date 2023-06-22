//
//  ContactsNavigationController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 22/06/2023.
//

import UIKit

class ContactsNavigationController: UINavigationController {
    
    weak var contactsModelController: ContactsModelController?

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
extension ContactsNavigationController {
    func initialize() {
        if let contactDetailsTableViewController = viewControllers.first as? ContactDetailsTableViewController {
            contactDetailsTableViewController.contactsModelController = contactsModelController
        }
    }
}
