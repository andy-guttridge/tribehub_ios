//
//  AddTribeMemberContainerViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 28/04/2023.
//

import UIKit

class AddTribeMemberContainerViewController: UIViewController {
    
    var delegateOfChild: AddTribeMemberTableViewControllerDelegate?
    var childTableView: AddTribeMemberTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tableViewController = segue.destination as? AddTribeMemberTableViewController {
            self.childTableView = tableViewController
            tableViewController.delegate = self.delegateOfChild
        }
    }
}

// MARK: private extension
private extension AddTribeMemberContainerViewController {
    func initialize() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Confirm", style: .plain, target: self, action: #selector(addNewTribeMember))
        self.title = "Add Tribe Member"
    }
    
    @objc func addNewTribeMember() {
        // Call method on child table view if user pressed confirm button
        self.childTableView?.userDidConfirm()
    }
}
