//
//  AccountTableTableViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 27/04/2023.
//

import UIKit

class AccountTableViewController: UITableViewController {
    weak var userModelController: UserModelController?
    weak var tribeModelController: TribeModelController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.checkTribeAdminStatus()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3 {
            // User selected table row 3, meaning they wish to delete their account
            var message = ""
            
            // Show an appropriate alert message to cancel or confirm depending on whether they are the
            // tribe administrator or a regular user
            if self.userModelController?.user?.isAdmin == true {
                message = "Are you sure you want to delete your user account and close down your tribe by deleting all your tribe members' accounts? This action cannot be undone."
            } else {
                message = "Are you sure you want to delete your user account? This action cannot be undone."
            }
            let actionSheet = UIAlertController(title: "Delete account", message: message, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Confirm", style: .destructive) {_ in
                if let pk = self.userModelController?.user?.pk {
                    Task.init {
                        do {
                            _ = try await self.userModelController?.doDeleteUser(forPrimaryKey: pk, isDeletingOwnAccount: true)
                        } catch {
                            print("Error deleting account")
                        }
                    }
                }
            })
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel) {_ in return })
            present(actionSheet, animated: true)
        }
        if indexPath.row == 4 {
            // Table row 4 means user selected logout
            guard let userModelController = self.userModelController else {
                return
            }
            
            Task.init {
                do {
                    _ = try await userModelController.doLogout()
                    self.checkTribeAdminStatus()
                } catch {
                    let alert = UIAlertController(title: "Logout Error", message:"There was an issue logging out.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: {alertAction in alert.dismiss(animated: true)}))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let manageTribeTableViewController = segue.destination as? ManageTribeTableViewController {
            manageTribeTableViewController.userModelController = self.userModelController
            manageTribeTableViewController.tribeModelController = self.tribeModelController
        }
        if let displayNameContainerViewController = segue.destination as? DisplayNameContainerViewController {
            displayNameContainerViewController.userModelController = self.userModelController
        }
        if let passwordContainerViewController = segue.destination as? PasswordContainerViewController {
            passwordContainerViewController.userModelController = self.userModelController
        }
    }
}

// MARK: private extension
private extension AccountTableViewController {
    /// Ensure manage tribe cell is only selectable if user is tribe admin,
    /// otherwise grey out and make unselectable
    func checkTribeAdminStatus() -> Void {
        if self.userModelController?.user?.isAdmin == true {
            let manageTribeCell = self.tableView(self.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
            manageTribeCell.isUserInteractionEnabled = true
            manageTribeCell.textLabel?.isEnabled = true
            manageTribeCell.imageView?.tintColor = .systemBlue
        } else {
            let manageTribeCell = self.tableView(self.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
            manageTribeCell.isUserInteractionEnabled = false
            manageTribeCell.textLabel?.isEnabled = false
            manageTribeCell.imageView?.tintColor = .gray
        }
    }
}
