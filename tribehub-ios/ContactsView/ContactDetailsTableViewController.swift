//
//  ContactDetailsTableViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 22/06/2023.
//

import UIKit

// MARK: ContactCell custom UITableViewCell class definition
class ContactCell: UITableViewCell {
    
    @IBOutlet weak var contactCellCategoryLabel: UILabel!
    @IBOutlet weak var contactCellCompanyLabel: UILabel!
    @IBOutlet weak var contactCellTitleLabel: UILabel!
    @IBOutlet weak var contactCellFirstNameLabel: UILabel!
    @IBOutlet weak var contactCellLastNameLabel: UILabel!
    @IBOutlet weak var contactCellTelLabel: UILabel!
    @IBOutlet weak var contactCellTellNumberLabel: UILabel!
    @IBOutlet weak var contactCellEmailLabel: UILabel!
    @IBOutlet weak var contactCellEmailAddressLabel: UILabel!
}


// MARK: ContactDetailsTableViewController class definition
class ContactDetailsTableViewController: UITableViewController {
    
    var contactsModelController: ContactsModelController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsModelController?.contacts?.count ?? 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initialize()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell
        if let category = contactsModelController?.contacts?.results[indexPath.row].category {
            cell.contactCellCategoryLabel.text = category
        }
        
        if let company = contactsModelController?.contacts?.results[indexPath.row].company {
            cell.contactCellCompanyLabel.text = company
        } else {
            cell.contactCellCompanyLabel.isHidden = true
        }
        
        if let title = contactsModelController?.contacts?.results[indexPath.row].title {
            cell.contactCellTitleLabel.text = title
        } else {
            cell.contactCellTitleLabel.isHidden = true
        }
        
        if let firstName = contactsModelController?.contacts?.results[indexPath.row].firstName {
            cell.contactCellFirstNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
            cell.contactCellFirstNameLabel.text = firstName
        } else {
            cell.contactCellLastNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
            cell.contactCellFirstNameLabel.isHidden = true
        }
        
        if let lastName = contactsModelController?.contacts?.results[indexPath.row].lastName {
            cell.contactCellLastNameLabel.text = lastName
        } else {
            cell.contactCellLastNameLabel.isHidden = true
        }
        
        if let telNumber = contactsModelController?.contacts?.results[indexPath.row].phone {
            cell.contactCellTellNumberLabel.text = telNumber
            if telNumber == "" {
                cell.contactCellTelLabel.isHidden = true
                cell.contactCellTellNumberLabel.isHidden = true
            }
        } else {
            cell.contactCellTelLabel.isHidden = true
            cell.contactCellTellNumberLabel.isHidden = true
        }
        
        if let email = contactsModelController?.contacts?.results[indexPath.row].email {
            cell.contactCellEmailAddressLabel.text = email
            if email == "" {
                cell.contactCellEmailLabel.isHidden = true
                cell.contactCellEmailAddressLabel.isHidden = true
            }
        } else {
            cell.contactCellEmailLabel.isHidden = true
            cell.contactCellEmailAddressLabel.isHidden = true
        }

        return cell
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

// MARK: private extension
extension ContactDetailsTableViewController {
    func initialize() {
        Task.init {
            let spinnerView = addSpinnerViewTo(self)
            do {
                try await contactsModelController?.getContacts()
                removeSpinnerView(spinnerView)
                tableView.reloadData()
            } catch {
                removeSpinnerView(spinnerView)
                print(error)
            }
        }
    }
}
