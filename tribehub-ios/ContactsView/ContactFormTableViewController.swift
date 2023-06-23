//
//  ContactFormTableViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 23/06/2023.
//

import UIKit

// MARK: ContactFormTableViewControllerDelegate protocol definition
protocol ContactFormTableViewControllerDelegate {
    func contactDetailsDidChange()
}

// MARK: ContactFormTableViewController class definition
class ContactFormTableViewController: UITableViewController {
    
    weak var contactsModelController: ContactsModelController?
    var delegate: ContactFormTableViewControllerDelegate?
    
    // Holds a contact to be edited
    var contact: Contact?
    
    // Properties to hold values of user input captured in tableViewCells
    // private var categoryString: String?
    // private var companyString: String?
    // private var titleString: String?
    // private var firstNameString: String?
    // private var lastNameString: String?
    // private var telString: String?
    // private var emailString: String?
    
    // MARK: IBOutlets
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var telNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
}

// MARK: public extension
extension ContactFormTableViewController {
    /// Handles user confirming form submission
    @objc func userDidConfirm() {
        guard let contactsModelController = contactsModelController else { return }
        
        var userDidEnterValidDetails = false
        
        // Get values from textFields
        let category = self.categoryTextField.text
        let company = self.companyTextField.text
        let title = self.titleTextField.text
        let firstName = self.firstNameTextField.text
        let lastName = self.lastNameTextField.text
        let telNumber = self.telNumberTextField.text
        let email = self.emailTextField.text
        
        // Check if value entered for companyTextField, show alert if not
        if category == "" {
            let errorAlert = makeErrorAlert(title: "You must enter a category", message: "You must enter a category. Please try again")
            present(errorAlert, animated: true) {
                userDidEnterValidDetails = false
            }
        } else {
                userDidEnterValidDetails = true
        }
        
        // If contact has a value, user must be editing an existing contact,
        // so handle as such. Otherwise, they must be creating a new contact and
        // we deal with it that way.
        if let contact = contact, let pk = contact.id {
            if userDidEnterValidDetails {
                Task.init {
                    let spinnerView = addSpinnerViewTo(self)
                    do {
                        try await contactsModelController.editContactForPk(
                            pk,
                            category: category,
                            company:company,
                            title: title,
                            firstName: firstName,
                            lastName: lastName,
                            telNumber: telNumber,
                            email: email
                        )
                        removeSpinnerView(spinnerView)
                        delegate?.contactDetailsDidChange()
                    } catch HTTPError.badRequest(let apiResponse) {
                        removeSpinnerView(spinnerView)
                        self.dismiss(animated: true, completion: nil)
                        let errorMessage = apiResponse
                        let errorAlert = makeErrorAlert(title: "Error editing contact", message: "The server reported an error: \n\n\(errorMessage)")
                        self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
                    } catch HTTPError.otherError(let statusCode) {
                        removeSpinnerView(spinnerView)
                        self.dismiss(animated: true, completion: nil)
                        let errorAlert = makeErrorAlert(title: "Error editing contact", message: "Something went wrong editing your contact. \n\nThe status code reported by the server was \(statusCode)")
                        self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
                    } catch {
                        removeSpinnerView(spinnerView)
                        self.dismiss(animated: true, completion: nil)
                        let errorAlert = makeErrorAlert(title: "Error editing contact", message: "Something went wrong editing your contact. Please check you are online.")
                        self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
                    }
                }
            }
            
        } else {
            // Make the API call to create a new contact
            if userDidEnterValidDetails {
                Task.init {
                    let spinnerView = addSpinnerViewTo(self)
                    do {
                        try await contactsModelController.createContact(
                            category: category,
                            company: company,
                            title: title,
                            firstName: firstName,
                            lastName: lastName,
                            telNumber: telNumber,
                            email: email
                        )
                        removeSpinnerView(spinnerView)
                        
                        // Inform the delegate that contact details have change. It will dismiss this view.
                        delegate?.contactDetailsDidChange()
                    } catch HTTPError.badRequest(let apiResponse) {
                        removeSpinnerView(spinnerView)
                        self.dismiss(animated: true, completion: nil)
                        let errorMessage = apiResponse
                        let errorAlert = makeErrorAlert(title: "Error creating contact", message: "The server reported an error: \n\n\(errorMessage)")
                        self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
                    } catch HTTPError.otherError(let statusCode) {
                        removeSpinnerView(spinnerView)
                        self.dismiss(animated: true, completion: nil)
                        let errorAlert = makeErrorAlert(title: "Error creating contact", message: "Something went wrong creating your contact. \n\nThe status code reported by the server was \(statusCode)")
                        self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
                    } catch {
                        removeSpinnerView(spinnerView)
                        self.dismiss(animated: true, completion: nil)
                        let errorAlert = makeErrorAlert(title: "Error creating contact", message: "Something went wrong creating your contact. Please check you are online.")
                        self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
                    }
                }
            }
        }
    }
}

// MARK: private extension
private extension ContactFormTableViewController {
    func initialize() {
        let contactDetailsSection = tableView.numberOfSections - 1
        
        // If a contact has been passed in the user must be editing a contact
        // and the tableView is configured appropriately
        if let contact = contact {
            // Give navigationItem appropriate title and add a confirm button if the form is being used to edit a contact
            navigationItem.title = "Edit contact"
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Confirm", style: .done, target: self, action: #selector(userDidConfirm))
            
            // Populate cell textfields with data from contact
            categoryTextField.text = contact.category
            companyTextField.text = contact.company
            titleTextField.text = contact.title
            firstNameTextField.text = contact.firstName
            lastNameTextField.text = contact.lastName
            telNumberTextField.text = contact.phone
            emailTextField.text = contact.email
        }
    }
}
