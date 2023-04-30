//
//  AddTribeMemberTableViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 28/04/2023.
//

import UIKit

protocol AddTribeMemberTableViewControllerDelegate {
    func addNewTribeMember(userName: String, password: String) async -> Void
    func dismissAddTribeMemberTableViewController() -> Void
}

class AddTribeMemberTableViewController: UITableViewController {
    
    var delegate: AddTribeMemberTableViewControllerDelegate?
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var password1TextField: UITextField!
    @IBOutlet weak var password2TextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func userDidConfirm() {
        var userDidEnterValidDetails = false
        let userName = self.userNameTextField.text
        let password1 = self.password1TextField.text
        let password2 = self.password2TextField.text
        
        // Check if text entered into all necessary fields, show alert if not
        if userName == "" || password1 == "" || password2 == "" {
            let errorAlert = makeErrorAlert(title: "You must complete all fields", message: "You must enter a username and your password into both password fields. Please try again.")
            self.present(errorAlert, animated: true) {
                userDidEnterValidDetails = false
            }
        } else if password1 != password2 {
            // Check if password fields match, show alert if not
            let errorAlert = makeErrorAlert(title: "Incorrect Password", message: "The two passwords do not match. Please try again.")
            self.present(errorAlert, animated: true) {
                userDidEnterValidDetails = false
            }
        } else {
            userDidEnterValidDetails = true
        }
        if userDidEnterValidDetails {
            Task.init {
                do {
                    if let userName = userName, let password = password1 {
                        self.delegate?.dismissAddTribeMemberTableViewController()
                        await self.delegate?.addNewTribeMember(userName: userName, password: password)
                    }
                } 
            }
        }
    }
}
