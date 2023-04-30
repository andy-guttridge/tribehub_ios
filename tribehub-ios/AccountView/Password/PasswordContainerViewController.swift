//
//  PasswordContainerViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 30/04/2023.
//

import UIKit

class PasswordContainerViewController: UIViewController, PasswordTableViewControllerDelegate {
    
    weak var childTableView: PasswordTableViewController?
    weak var userModelController: UserModelController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Confirm", style: .plain, target: self, action: #selector(didChangePassword))
    }
    
    @objc func didChangePassword() {
        self.childTableView?.didChangePassword()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tableViewController = segue.destination as? PasswordTableViewController {
            self.childTableView = tableViewController
            tableViewController.delegate = self
        }
    }
    
    func changePassword(newPassword: String, oldPassword: String) async {
        guard let pk = self.userModelController?.user?.pk else {
            return
        }
        do {
            _ = try await self.userModelController?.doUpdatePassword(forPrimaryKey: pk, newPassword: newPassword, oldPassword: oldPassword)
        } catch HTTPError.badRequest(let apiResponse) {
            let errorMessage = apiResponse.values.reduce("", {acc, str  in str + "\n"})
            let errorAlert = makeErrorAlert(title: "Error changing password", message: "The server reported an error: \n\n\(errorMessage)")
            self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
        } catch {
            let errorAlert = makeErrorAlert(title: "Error changing password", message: "Something went wrong changing your password. Please check you are online and logged in.")
            print ("Error! ", error)
            self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
        }
    }
    
    func dismissPasswordTableViewController() {
        self.navigationController?.popViewController(animated: true)
    }
}
