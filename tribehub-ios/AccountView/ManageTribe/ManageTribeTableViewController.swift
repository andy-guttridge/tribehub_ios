//
//  ManageTribeTableViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 27/04/2023.
//

import UIKit
import Alamofire

class AddTribeMemberTableViewCell: UITableViewCell {
    @IBOutlet weak var addImage: UIImageView!
    @IBOutlet weak var addLabel: UILabel!
}

class TribeMemberTableViewCell: UITableViewCell {
    @IBOutlet weak var tribeMemberImageView: UIImageView!
    @IBOutlet weak var tribeMemberDisplayNameLabel: UILabel!
}

class ManageTribeTableViewController: UITableViewController, AddTribeMemberTableViewControllerDelegate {
    
    weak var userModelController: UserModelController?
    weak var tribeModelController: TribeModelController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 68
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return self.tribeModelController?.tribe?.tribeMembers.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddTribeMemberCell", for: indexPath) as! AddTribeMemberTableViewCell
            if tableView.isEditing {
                cell.addImage.tintColor = UIColor(named: "THGreyed")
                cell.addLabel.isEnabled = false
            }
            
            // Align separator with right of profile images
            cell.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 0)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TribeMemberCell", for: indexPath) as! TribeMemberTableViewCell
            cell.tribeMemberDisplayNameLabel.text = self.tribeModelController?.tribe?.tribeMembers[indexPath.row].displayName
            cell.tribeMemberImageView.makeRounded()
            cell.tribeMemberImageView.image = self.tribeModelController?.tribe?.tribeMembers[indexPath.row].profileImage
            
            // Align separator with right of profile image
            cell.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 0)
            return cell
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        }
        if self.userModelController?.user?.pk == self.tribeModelController?.tribe?.tribeMembers[indexPath.row].pk {
            return false
        }
        return true
    }
    
    // // Ensures add tribeMember cell is redrawn when editing status changes
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableView.RowAnimation.none)
    }
    
    /// Attempts to delete tribe member from the backend and remove from the manage tribe table if successful
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Task.init {
                let spinnerView = addSpinnerViewTo(self)
                do {
                    if let userPk = tribeModelController?.tribe?.tribeMembers[indexPath.row].pk {
                        _ = try await self.tribeModelController?.doDeleteTribeMember(forPrimaryKey: userPk)
                        removeSpinnerView(spinnerView)
                    }
                    tableView.deleteRows(at: [indexPath], with: .fade)
                } catch {
                    removeSpinnerView(spinnerView)
                    let errorAlert = makeErrorAlert(title: "Error deleting tribe member", message: "Something went wrong deleting this tribe member. Please check you are online and logged in.")
                    self.present(errorAlert, animated: true) {return}
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let containerViewController = segue.destination as? AddTribeMemberContainerViewController {
            print("Found containerViewControllerSegue")
            containerViewController.delegateOfChild = self
        }
    }
    
    func addNewTribeMember(userName: String, password: String) async {
        let spinnerView = addSpinnerViewTo(self)
        do {
            _ = try await self.tribeModelController?.doAddTribeMember(withUserName: userName, passWord: password)
            removeSpinnerView(spinnerView)
            self.tableView?.reloadData()
        } catch HTTPError.badRequest(let apiResponse) {
            removeSpinnerView(spinnerView)
            let errorMessage = apiResponse
            let errorAlert = makeErrorAlert(title: "Error adding tribe member", message: "The server reported an error: \n\n\(errorMessage)")
            self.present(errorAlert, animated: true) {return}
        } catch {
            removeSpinnerView(spinnerView)
            let errorAlert = makeErrorAlert(title: "Error adding tribe member", message: "Something went wrong adding this tribe member. Please check you are online and logged in.")
            print ("Error! ", error)
            self.present(errorAlert, animated: true) {return}
        }
    }
    
    func dismissAddTribeMemberTableViewController() {
        self.navigationController?.popViewController(animated: true)
    }
}
