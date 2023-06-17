//
//  CalEventDetailsViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 19/05/2023.
//

import UIKit

// MARK: CalEventDetailsViewControllerDelegate protocol declaration
protocol CalEventDetailsViewControllerDelegate {
    func calEventDetailsDidChange(shouldDismissSubview: Bool, event: Event?) async throws
}

// MARK: CalEventDetailsViewController class declaration
class CalEventDetailsViewController: UIViewController {
    
    weak var userModelController: UserModelController?
    weak var tribeModelController: TribeModelController?
    weak var eventsModelController: EventsModelController?
    
    weak var calEventDetailsTableViewControllerDelegate: HomeViewController?
    
    var delegate: CalEventDetailsViewControllerDelegate?
    
    // event holds the event the user selected to view details of
    var event: Event?
    
    // originalEvent holds the orginal event if a user selected to edit
    // a recurrence
    private var originalEvent: Event?

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the event and modelControllers to the CalEventDetailsTableViewController and set the delegate
        // if that is the segue destination
        if let calEventTableViewController = segue.destination as? CalEventDetailsTableViewController {
            calEventTableViewController.event = event
            calEventTableViewController.userModelController = userModelController
            calEventTableViewController.tribeModelController = tribeModelController
            calEventTableViewController.eventsModelController = eventsModelController
            calEventTableViewController.delegate = calEventDetailsTableViewControllerDelegate
        }
        
        // Pass the event and modelControllers to the EventFormTableViewController and set the delegate
        // if that is the segue destination
        if let eventFormTableViewController = segue.destination as? EventFormTableViewController {
            eventFormTableViewController.userModelController = userModelController
            eventFormTableViewController.tribeModelController = tribeModelController
            eventFormTableViewController.eventsModelController = eventsModelController
            eventFormTableViewController.delegate = self
            
            if let originalEvent = originalEvent {
                eventFormTableViewController.event = originalEvent
            } else {
                eventFormTableViewController.event = event
            }
        }
    }
}

// MARK: Private methods extension
private extension CalEventDetailsViewController {
    func initialize() {
        title = "Event details"
        
        // Add an edit rightBarButtonItem if the user is the tribeAdmin or
        // if they are the owner of the event
        if let user = userModelController?.user, let ownerPk = event?.owner?.pk {
            if user.isAdmin ?? false || ownerPk == user.pk {
                let changeEventAction = UIAction(title: "Change", image: UIImage(systemName: "pencil")) { _ in
                    self.editEvent()
                }
                
                let deleteEventAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                    self.deleteEvent()
                }
                
                let menu = UIMenu(children: [changeEventAction, deleteEventAction])
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", menu: menu)
                // navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editEvent))
            }
        }
    }
    
    /// Handles user selecting to edit the event by performing a segue way to EventFormTableViewController
    func editEvent() {
        
        // If the event instance the user has chosen to edit is a recurrence, we don't want them trying to
        // make an edit to it directly, as this is not supported by the API. Instead, we attempt to fetch the original
        // event from which the recurrence was generated from the API and alert the user that any edits will
        // be made to the original. They can then either cancel, or proceed to edit the original event.
        if event?.recurrenceType == "REC" {
            Task.init {
                let spinnerView = addSpinnerViewTo(self)
                do {
                    originalEvent = try await eventsModelController?.getEventForPk(event?.id)
                    removeSpinnerView(spinnerView)
                    let alert = UIAlertController(title: "Editing original event", message: "You chose to edit an event recurrence. Any edits will be made to the original event.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action"), style: .cancel, handler: {alertAction in alert.dismiss(animated: true)}))
                    
                    // The OK action includes a handler to perform the segue to the EventFormTableViewController
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Confirm action"), style: .default, handler: {alertAction in self.performSegue(withIdentifier: "EventEditSegue", sender: self)}))
                    self.view.window?.rootViewController?.present(alert, animated: true) {return}
                } catch HTTPError.badRequest(let apiResponse) {
                    removeSpinnerView(spinnerView)
                    self.dismiss(animated: true, completion: nil)
                    let errorMessage = apiResponse
                    let errorAlert = makeErrorAlert(title: "Error fetching original event", message: "You chose to edit an event recurrence.\n\nWe attempted to fetch the details of the original event, but the server reported an error: \n\n\(errorMessage)")
                    self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
                } catch HTTPError.otherError(let statusCode) {
                    removeSpinnerView(spinnerView)
                    self.dismiss(animated: true, completion: nil)
                    let errorAlert = makeErrorAlert(title: "Error fetching original event", message: "You chose to edit an event recurrence.\n\nWe attempted to fetch the details of the original event, but something went wrong.\n\nThe status code reported by the server was \(statusCode).")
                    self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
                } catch {
                    removeSpinnerView(spinnerView)
                    self.dismiss(animated: true, completion: nil)
                    let errorAlert = makeErrorAlert(title: "Error editing event", message: "You chose to edit an event recurrence.\n\nWe attempted to fetch the details of the original event, but something went wrong.\n\nPlease check you are online.")
                    self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
                }
            }
        } else {
            performSegue(withIdentifier: "EventEditSegue", sender: self)
        }
    }
}

// MARK: EventForTableViewControllerDelegate extension
extension CalEventDetailsViewController: EventFormTableViewControllerDelegate {
    func calEventDetailsDidChange(shouldDismissSubview: Bool, event: Event?) async throws {
        guard let eventsModelController = eventsModelController, let event = event else { return }
        
        if let calEventTableViewController = self.children[0] as? CalEventDetailsTableViewController {
            calEventTableViewController.event = event
            calEventTableViewController.eventDidChange()
        } else {
            print("Did not find calEventTableViewController")
        }
        let spinnerView = addSpinnerViewTo(self)
        try await eventsModelController.getEvents()
        removeSpinnerView(spinnerView)
        navigationController?.popViewController(animated: true)
    }
    
    /// Handles user selecting to delete an event
    func deleteEvent() {
        guard let eventPk = event?.id, let event = event else { return }
        
        // Create an appropriate message for the confirmation action sheet depending on whether this is
        // a recurring event, a recurrence or a non-repeating event, and display in an action sheet with
        // cancel and confirm options.
        var message = ""
        if event.recurrenceType == "REC" {
            message = "You have chosen to delete an event recurrence\n\nThis will permanently delete the original event and all its recurrences."
        } else if event.recurrenceType == "NON" {
            message = "This event will be permanently deleted"
        } else {
            message = "You have chosen to delete a recurring event\n\nThis will permanently delete the original event and all its recurrences"
        }
        let actionSheet = UIAlertController(title: "Delete event", message: message, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Confirm", style: .destructive) { _ in
            
            // Attempt to delete the event
            Task.init {
                let spinnerView = addSpinnerViewTo(self)
                do {
                    try await self.eventsModelController?.deleteEventForPk(eventPk)
                    removeSpinnerView(spinnerView)
                } catch HTTPError.badRequest(let apiResponse) {
                    removeSpinnerView(spinnerView)
                    self.dismiss(animated: true, completion: nil)
                    let errorMessage = apiResponse
                    let errorAlert = makeErrorAlert(title: "Error deleting event", message: "The server reported an error: \n\n\(errorMessage)")
                    self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
                } catch HTTPError.otherError(let statusCode) {
                    removeSpinnerView(spinnerView)
                    self.dismiss(animated: true, completion: nil)
                    let errorAlert = makeErrorAlert(title: "Error deleting event", message: "Something went wrong deleting your event. \n\nThe status code reported by the server was \(statusCode)")
                    self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
                } catch {
                    removeSpinnerView(spinnerView)
                    self.dismiss(animated: true, completion: nil)
                    let errorAlert = makeErrorAlert(title: "Error deleting event", message: "Something went wrong deleting your event. Please check you are online.")
                    self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
                }
                
                // Tell the delegate to dismiss this view controller.
                do {
                    try await self.delegate?.calEventDetailsDidChange(shouldDismissSubview: true, event: event)
                } catch {
                    print("CalEventDetailsViewController delegate threw an error fetching events and updating calendar")
                }
            }            
        })
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in return })
        present(actionSheet, animated: true)
    }
}
