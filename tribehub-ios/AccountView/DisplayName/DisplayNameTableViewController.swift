//
//  DisplayNameTableTableViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 30/04/2023.
//

import UIKit

protocol DisplayNameTableViewControllerDelegate {
    func changeDisplayName(displayName: String) async -> Void
    func dismissDisplayNameTableViewController() -> Void
}

class DisplayNameTableViewController: UITableViewController {
    
    var delegate: DisplayNameTableViewControllerDelegate?
    var displayName: String?
    
    @IBOutlet weak var displayNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
}

// MARK: private extension
private extension DisplayNameTableViewController {
    func initialize() {
        self.displayNameTextField.text = displayName
    }
}

// MARK: public extension
extension DisplayNameTableViewController {
    func didChangeDisplayName() {
        Task.init {
            do {
                self.delegate?.dismissDisplayNameTableViewController()
                await delegate?.changeDisplayName(displayName: self.displayNameTextField.text ?? "")
            }
        }
    }
}
