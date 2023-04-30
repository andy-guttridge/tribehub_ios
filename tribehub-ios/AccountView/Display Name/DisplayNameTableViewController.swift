//
//  DisplayNameTableTableViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 30/04/2023.
//

import UIKit

protocol DisplayNameTableViewControllerDelegate {
    func changeDisplayName(displayName: String) async -> Void
    func dismissDisplayTribeMemberTableViewController() -> Void
}

class DisplayNameTableViewController: UITableViewController {
    
    var delegate: DisplayNameTableViewControllerDelegate?
    var displayName: String?
    
    @IBOutlet weak var displayNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.displayNameTextField.text = displayName
    }
    
    func didChangeDisplayName() {
        Task.init {
            do {
                self.delegate?.dismissDisplayTribeMemberTableViewController()
                await delegate?.changeDisplayName(displayName: self.displayNameTextField.text ?? "")
            }
        }
    }
}
