//
//  ManageTribeTableViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 27/04/2023.
//

import UIKit
import Alamofire

class TribeMemberTableViewCell: UITableViewCell {
    @IBOutlet weak var tribeMemberImageView: UIImageView!
    @IBOutlet weak var tribeMemberDisplayNameLabel: UILabel!
}

class ManageTribeTableViewController: UITableViewController {
    weak var userModelController: UserModelController?
    weak var tribeModelController: TribeModelController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 68
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tribeModelController?.tribe?.tribeMembers.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> TribeMemberTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TribeMemberCell", for: indexPath) as! TribeMemberTableViewCell
        cell.tribeMemberDisplayNameLabel.text = self.tribeModelController?.tribe?.tribeMembers[indexPath.row].displayName
        cell.tribeMemberImageView.makeRounded()
        cell.tribeMemberImageView.image = self.tribeModelController?.tribe?.tribeMembers[indexPath.row].profileImage
        cell.frame.size.height = 120
        return cell
    }

    

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if self.userModelController?.user?.pk == self.tribeModelController?.tribe?.tribeMembers[indexPath.row].pk {
            return false
        }
        return true
    }
    
    /// Attempts to delete tribe member from the backend and remove from the manage tribe table if successful
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Task.init {
                do {
                    if let userPk = tribeModelController?.tribe?.tribeMembers[indexPath.row].pk {
                        let result = try await self.tribeModelController?.doDeletTribeMember(forPrimaryKey: userPk)
                        print(result)
                    }
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
                catch {
                    let errorAlert = makeErrorAlert(title: "Error deleting tribe member", message: "Something went wrong deleting this tribe member. Please check you are online and logged in.")
                    self.present(errorAlert, animated: true) {return}
                }
            }
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
