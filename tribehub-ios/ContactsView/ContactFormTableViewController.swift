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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
}

// MARK: public extension
extension ContactFormTableViewController {
    /// Handles user confirming form submission
    func userDidConfirm() {
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
