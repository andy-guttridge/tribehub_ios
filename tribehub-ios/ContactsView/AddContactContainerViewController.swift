//
//  AddContactContainerViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 23/06/2023.
//

import UIKit

class AddContactContainerViewController: UIViewController {
    
    var childTableView: ContactFormTableViewController?
    var contactsModelController: ContactsModelController?
    
    // Delegate to pass through to the ContactFormTableViewController
    var contactFormTableViewControllerDelegate: ContactFormTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tableViewController = segue.destination as? ContactFormTableViewController {
            childTableView = tableViewController
            tableViewController.contactsModelController = contactsModelController
            tableViewController.delegate = contactFormTableViewControllerDelegate
        }
    }
}

// MARK: private extension
private extension AddContactContainerViewController {
    func initialize() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Confirm", style: .done, target: self, action: #selector(confirmSubmit))
    }
    
    /// Handles user pressing the confirm submit button by calling a method on the child tableView
    @objc func confirmSubmit() {
        childTableView?.userDidConfirm()
    }
}
