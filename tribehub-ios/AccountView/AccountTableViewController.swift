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
            print("Did select delete account")
        }
        if indexPath.row == 4 {
            // User selected logout
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
