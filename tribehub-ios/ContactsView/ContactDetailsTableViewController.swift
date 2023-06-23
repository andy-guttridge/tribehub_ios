//
//  ContactDetailsTableViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 22/06/2023.
//

import UIKit

// MARK: ContactCell custom UITableViewCell class definition
class ContactCell: UITableViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var contactCellCategoryLabel: UILabel!
    @IBOutlet weak var contactCellCompanyLabel: UILabel!
    @IBOutlet weak var contactCellTitleLabel: UILabel!
    @IBOutlet weak var contactCellFirstNameLabel: UILabel!
    @IBOutlet weak var contactCellLastNameLabel: UILabel!
    @IBOutlet weak var contactCellTelLabel: UILabel!
    @IBOutlet weak var contactCellTelNumberLabel: UILabel!
    @IBOutlet weak var contactCellEmailLabel: UILabel!
    @IBOutlet weak var contactCellEmailAddressLabel: UILabel!
}


// MARK: ContactDetailsTableViewController class definition
class ContactDetailsTableViewController: UITableViewController {
    
    weak var contactsModelController: ContactsModelController?
    weak var userModelController: UserModelController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // If user has tribeAdmin status, we will need to display an add contact cell in its own section
        if let isAdmin = userModelController?.user?.isAdmin {
            if isAdmin {
                return 2
            }
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let isAdmin = userModelController?.user?.isAdmin else {
            return 0
        }
        
        // Section 0 is the section with the add contact cell if the user is tribeAdmin, so
        // only needs one cell
        if isAdmin && section == 0 {
            return 1
        }
        
        return contactsModelController?.contacts?.count ?? 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initialize()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let isAdmin = userModelController?.user?.isAdmin else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
            return cell
        }
        
        // If user is tribeAdmin and section is 0, configure and return an AddContactCell, otherwise
        // configure a cell for the contact corresponding with the row number
        if isAdmin && indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddContactCell", for: indexPath)
            return cell
        } else {
            // Populate category
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell
            if let category = contactsModelController?.contacts?.results[indexPath.row].category {
                cell.contactCellCategoryLabel.text = category
            }
            
            // Populate company
            if let company = contactsModelController?.contacts?.results[indexPath.row].company {
                cell.contactCellCompanyLabel.text = company
            }
            
            // Populate title
            if let title = contactsModelController?.contacts?.results[indexPath.row].title {
                cell.contactCellTitleLabel.text = title
            }
            
            // Populate firstName. Hide if no value
            if let firstName = contactsModelController?.contacts?.results[indexPath.row].firstName {
                cell.contactCellFirstNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
                cell.contactCellFirstNameLabel.text = firstName
            } else {
                cell.contactCellLastNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
                cell.contactCellFirstNameLabel.isHidden = true
            }
            
            // Populate lastName
            if let lastName = contactsModelController?.contacts?.results[indexPath.row].lastName {
                cell.contactCellLastNameLabel.text = lastName
            } else {
                cell.contactCellLastNameLabel.isHidden = true
            }
            
            // Populate telNumer and hide if no value
            if let telNumber = contactsModelController?.contacts?.results[indexPath.row].phone {
                cell.contactCellTelNumberLabel.text = telNumber
                if telNumber == "" {
                    cell.contactCellTelNumberLabel.isHidden = true
                }
            } else {
                cell.contactCellTelNumberLabel.isHidden = true
            }
            
            // Populate email and hide if no value
            if let email = contactsModelController?.contacts?.results[indexPath.row].email {
                cell.contactCellEmailAddressLabel.text = email
                if email == "" {
                    cell.contactCellEmailAddressLabel.isHidden = true
                }
            } else {
                cell.contactCellEmailAddressLabel.isHidden = true
            }
            return cell
        }
    }
    
    // MARK: tableView size methods
    // Resize the cell if the content is too big (e.g. a long event subject).
    // Approach to overriding this method to cause a specific cell to autoresize is from
    // https://www.hackingwithswift.com/example-code/uikit/how-to-make-uitableviewcells-auto-resize-to-their-content
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let isAdmin = userModelController?.user?.isAdmin else { return 68 }
        if indexPath.section == 0 && isAdmin {
            return 68
        }
        else {
            return 200
        }
    }
    
    // Approach to overriding this method to cause a specific cell to autoresize is from
    // https://www.hackingwithswift.com/example-code/uikit/how-to-make-uitableviewcells-auto-resize-to-their-content
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableView.automaticDimension
        }
        else {
            return 68
        }
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

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addContactContainerViewController = segue.destination as? AddContactContainerViewController {
            addContactContainerViewController.contactsModelController = contactsModelController
            addContactContainerViewController.contactFormTableViewControllerDelegate = self
        }
    }
}

// MARK: private extension
private extension ContactDetailsTableViewController {
    func initialize() {
        
        Task.init {
            // Fetch contacts from the API
            let spinnerView = addSpinnerViewTo(self)
            do {
                try await contactsModelController?.getContacts()
                removeSpinnerView(spinnerView)
                tableView.reloadData()
            } catch HTTPError.badRequest(let apiResponse) {
                removeSpinnerView(spinnerView)
                self.dismiss(animated: true, completion: nil)
                let errorMessage = apiResponse
                let errorAlert = makeErrorAlert(title: "Error fetching contacts", message: "The server reported an error: \n\n\(errorMessage)")
                self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
            } catch HTTPError.otherError(let statusCode) {
                removeSpinnerView(spinnerView)
                self.dismiss(animated: true, completion: nil)
                let errorAlert = makeErrorAlert(title: "Error fetching contacts", message: "Something went wrong fetching your contacts. \n\nThe status code reported by the server was \(statusCode)")
                self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
            } catch {
                removeSpinnerView(spinnerView)
                self.dismiss(animated: true, completion: nil)
                let errorAlert = makeErrorAlert(title: "Error fetching contacts", message: "Something went wrong fetching your contacts. Please check you are online.")
                self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
            }
        }
    }
}

// MARK: ContactFormTableViewControllerDelegate extension
extension ContactDetailsTableViewController: ContactFormTableViewControllerDelegate {
    func contactDetailsDidChange() {
        // Dismiss the child view controller if contacts details changed
        navigationController?.popViewController(animated: true)
    }    
}

