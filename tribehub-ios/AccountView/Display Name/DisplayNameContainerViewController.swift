//
//  DisplayNameContainerViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 30/04/2023.
//

import UIKit

class DisplayNameContainerViewController: UIViewController, DisplayNameTableViewControllerDelegate {
    
    weak var childTableView: DisplayNameTableViewController?
    weak var userModelController: UserModelController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Confirm", style: .plain, target: self, action: #selector(didChangeDisplayName))
    }
    
    @objc func didChangeDisplayName() {
        self.childTableView?.didChangeDisplayName()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tableViewController = segue.destination as? DisplayNameTableViewController {
            self.childTableView = tableViewController
            tableViewController.delegate = self
            tableViewController.displayName = self.userModelController?.user?.displayName
        }
    }
    
    func changeDisplayName(displayName: String) async {
        guard let pk = self.userModelController?.user?.pk else {
            return
        }
        do {
            _ = try await self.userModelController?.doUpdateProfile(forPrimaryKey: pk, payload: ["display_name": displayName])
            
        } catch HTTPError.badRequest(let apiResponse) {
            let errorMessage = apiResponse.values.reduce("", {acc, str  in str + "\n"})
            let errorAlert = makeErrorAlert(title: "Error changing display name", message: "The server reported an error: \n\n\(errorMessage)")
            self.present(errorAlert, animated: true) {return}
        } catch {
            let errorAlert = makeErrorAlert(title: "Error changing display name", message: "Something went wrong changing your display name. Please check you are online and logged in.")
            print ("Error! ", error)
            self.present(errorAlert, animated: true) {return}
        }
    }
    
    func dismissDisplayTribeMemberTableViewController() {
        self.navigationController?.popViewController(animated: true)
    }
}
