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

// MARK: AddContact custom UITableViewCell class definition
class AddContactCell: UITableViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var addImage: UIImageView!
    @IBOutlet weak var addLabel: UILabel!
}


// MARK: ContactDetailsTableViewController class definition
class ContactDetailsTableViewController: UITableViewController {
    
    weak var contactsModelController: ContactsModelController?
    weak var userModelController: UserModelController?
    
    private var selectedRow: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
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
        return contactsModelController?.contacts?.results.count ?? 0
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddContactCell", for: indexPath) as! AddContactCell
            if tableView.isEditing {
                cell.addImage.tintColor = UIColor(named: "THGreyed")
                cell.addLabel.isEnabled = false
                cell.isUserInteractionEnabled = false
            } else {
                cell.addImage.tintColor = UIColor(named: "THPositive")
                cell.addLabel.isEnabled = true
                cell.isUserInteractionEnabled = true
            }
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

    // MARK: tableView editing methods
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let isAdmin = userModelController?.user?.isAdmin else { return false }
        
        // If user isAdmin and section is 0, then this must be the add contact cell, so no editable
        if isAdmin && indexPath.section == 0 {
            return false
        }
        
        // Otherwise, it must be a contact cell. Editable if admin, otherwise not editable
        if isAdmin {
            return true
        }
        
        return false
    }
    
    // Ensures add contact cell is redrawn when editing status changes
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableView.RowAnimation.none)
    }
    


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Task.init {
                let spinnerView = addSpinnerViewTo(self)
                do {
                    if let contactPk = contactsModelController?.contacts?.results[indexPath.row].id {
                        try await contactsModelController?.deleteContactForPk(contactPk)
                        removeSpinnerView(spinnerView)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                } catch HTTPError.badRequest(let apiResponse) {
                    removeSpinnerView(spinnerView)
                    self.dismiss(animated: true, completion: nil)
                    let errorMessage = apiResponse
                    let errorAlert = makeErrorAlert(title: "Error deleting contact", message: "The server reported an error: \n\n\(errorMessage)")
                    self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
                } catch HTTPError.otherError(let statusCode) {
                    removeSpinnerView(spinnerView)
                    self.dismiss(animated: true, completion: nil)
                    let errorAlert = makeErrorAlert(title: "Error deleting contact", message: "Something went wrong deleting your contact. \n\nThe status code reported by the server was \(statusCode)")
                    self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
                } catch {
                    removeSpinnerView(spinnerView)
                    self.dismiss(animated: true, completion: nil)
                    let errorAlert = makeErrorAlert(title: "Error deleting contact", message: "Something went wrong deleting your contact. Please check you are online.")
                    self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
                }
            }
        } 
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addContactContainerViewController = segue.destination as? AddContactContainerViewController {
            addContactContainerViewController.contactsModelController = contactsModelController
            addContactContainerViewController.contactFormTableViewControllerDelegate = self
        }
        
        if let contactFormTableViewController = segue.destination as? ContactFormTableViewController, let selectedRow = selectedRow {
            contactFormTableViewController.contactsModelController = contactsModelController
            contactFormTableViewController.delegate = self
            // Pass the contact the user wishes to edit to the form
            contactFormTableViewController.contact = contactsModelController?.contacts?.results[selectedRow]
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // If there is a section 1, then the user must be tribeAdmin, as we only have section 0
        // if the user isn't admin
        if indexPath.section == 1 && tableView.isEditing {
            selectedRow = indexPath.row
            performSegue(withIdentifier: "EditContactSegue", sender: indexPath)
        }
    }
}

// MARK: private extension
private extension ContactDetailsTableViewController {
    func initialize() {
        // Show edit button if user is tribeAdmin.
        // This is called from viewWillAppear and has an else statement to clear the
        // edit button to ensure it is reset if a different user logs in.
        if let isAdmin = userModelController?.user?.isAdmin {
            if isAdmin {
                navigationItem.rightBarButtonItem = self.editButtonItem
            } else {
                navigationItem.rightBarButtonItem = nil
            }
        }
        
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

