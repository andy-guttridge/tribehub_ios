//
//  CalEventDetailsViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 19/05/2023.
//

import UIKit

class CalEventDetailsViewController: UIViewController {
    
    weak var userModelController: UserModelController?
    weak var tribeModelController: TribeModelController?
    weak var eventsModelController: EventsModelController?
    
    weak var calEventDetailsTableViewControllerDelegate: HomeViewController?
    
    var event: Event?

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
            eventFormTableViewController.event = event
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
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editEvent))
            }
        }
    }
    
    /// Handles user selecting to edit the event by performing a segue way to EventFormTableViewController
    @objc func editEvent() {
        performSegue(withIdentifier: "EventEditSegue", sender: self)
    }
}

// MARK: EventForTableViewControllerDelegate extension
extension CalEventDetailsViewController: EventFormTableViewControllerDelegate {
    func calEventDetailsDidChange(shouldDismissSubview: Bool, event: Event?) async throws {
        guard let eventsModelController = eventsModelController, let event = event else { return }
        
        if let calEventTableViewController = self.children[0] as? CalEventDetailsTableViewController {
            print("Found calEventTableViewController")
            calEventTableViewController.event = event
            calEventTableViewController.eventDidChange()
        } else {
            print("Did not find calEventTableViewController")
        }
        try await eventsModelController.getEvents()        
        navigationController?.popViewController(animated: true)
    }
}
