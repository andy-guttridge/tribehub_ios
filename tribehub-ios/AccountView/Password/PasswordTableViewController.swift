//
//  PasswordTableViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 30/04/2023.
//

import UIKit

protocol PasswordTableViewControllerDelegate {
    func changePassword(newPassword: String, oldPassword: String) async -> Void
    func dismissPasswordTableViewController() -> Void
}

class PasswordTableViewController: UITableViewController {
    
    var delegate: PasswordTableViewControllerDelegate?

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var reenterPasswordTextField: UITextField!
    @IBOutlet weak var oldPassWordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: Public extension
extension PasswordTableViewController {
    func didChangePassword() {
        guard let password = passwordTextField.text, let oldPassword = oldPassWordTextField.text else {
            return
        }
        var userDidEnterValidData = true
        
        if passwordTextField.text == "" || reenterPasswordTextField.text ==  "" || oldPassWordTextField.text == "" {
            let errorAlert = makeErrorAlert(title: "Empty fields", message: "You need to enter matching new passwords and your old password before you can submit.")
            self.present(errorAlert, animated: true) {return}
            userDidEnterValidData = false
        }
        
        if passwordTextField.text != reenterPasswordTextField.text {
            let errorAlert = makeErrorAlert(title: "Passwords don't match", message: "Please make sure you have entered the same new password in both new password fields.")
            self.present(errorAlert, animated: true) {return}
            userDidEnterValidData = false
        }
        
        if userDidEnterValidData {
            Task.init {
                do {
                    self.delegate?.dismissPasswordTableViewController()
                    await delegate?.changePassword(newPassword: password, oldPassword: oldPassword)
                }
            }
        }
    }
}
