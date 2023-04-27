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
        
        // Enable manage tribe cell if user is tribe admin
        if self.userModelController?.user?.isAdmin == true {
            let manageTribeCell = self.tableView(self.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
            manageTribeCell.isUserInteractionEnabled = true
            manageTribeCell.textLabel?.isEnabled = true
            manageTribeCell.imageView?.tintColor = .systemBlue
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3 {
            print("Did select delete account")
        }
        if indexPath.row == 4 {
            print("Did select logout")
        }
    }

}
