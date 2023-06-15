//
//  HomeViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 12/05/2023.
//

import UIKit

class HomeViewController: UIViewController {
    weak var tribeModelController: TribeModelController?
    weak var userModelController: UserModelController?
    weak var eventsModelController: EventsModelController?
    
    var calendarViewController: CalendarViewController?
    var calendarTableViewController: CalEventTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let eventFormTableViewController = segue.destination as? EventFormTableViewController {
            eventFormTableViewController.userModelController = userModelController
            eventFormTableViewController.tribeModelController = tribeModelController
            eventFormTableViewController.eventsModelController = eventsModelController
            eventFormTableViewController.delegate = self
        }
    }
}

// MARK: private extensions
extension HomeViewController {
    func initialize() {
        if let calendarViewController = self.children[0] as? CalendarViewController {
            calendarViewController.eventsModelController = eventsModelController
            calendarViewController.delegate = self
            self.calendarViewController = calendarViewController
        }
        if let calEventTableViewController = self.children[1] as? CalEventTableViewController {
            calendarTableViewController = calEventTableViewController
            calendarTableViewController?.userModelController = userModelController
            calendarTableViewController?.tribeModelController = tribeModelController
            calendarTableViewController?.eventsModelController = eventsModelController
            calEventTableViewController.calEventDetailsTableViewControllerDelegate = self
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addEvent))
    }
    
    @objc func addEvent() {
        performSegue(withIdentifier: "EventFormSegue", sender: self)
    }
}

// MARK: CalendarViewControllerDelegate extension
extension HomeViewController: CalendarViewControllerDelegate {
    func didSelectCalendarDate(_ dateComponents: DateComponents) {
        guard let eventsModelController = eventsModelController else { return }
        calendarTableViewController?.eventsDidChange(events: eventsModelController.getEventsForDateComponents(dateComponents))
    }
}

// MARK: CalEventDetailsTableViewControllerDelegate, EventFormTableViewControllerDelegate, CalEventDetailsViewController extension
extension HomeViewController: CalEventDetailsTableViewControllerDelegate, EventFormTableViewControllerDelegate, CalEventDetailsViewControllerDelegate {
    
    /// Fetches fresh events data from the API, reloads data for the calendarTableView and refreshes calendar decorations
    /// - shouldDismissSubview: Bool - tells the function whether the view of the view controller that called this delegate method should be dismissed
    func calEventDetailsDidChange(shouldDismissSubview: Bool, event: Event?) async throws {
        guard let eventsModelController = eventsModelController, let calendarViewController = calendarViewController, let calEventTableViewController = self.children[1] as? CalEventTableViewController else { return }
        
        try await eventsModelController.getEvents()
        calendarTableViewController?.tableView.reloadData()
        calendarViewController.refreshCalDecorationsForCurrentMonth()
        
        // If an existing event has been passed in, that means the user has edited an event,
        // so we ask the calEventTableViewController to refresh its events for the relevant date
        // to ensure the changes to the event are reflected in the UI
        if let start = event?.start, let calendar = calendarViewController.calendarView?.calendar {
            let dateComponents = calendar.dateComponents([.day, .month, .year], from: start)
            calEventTableViewController.eventsDidChange(events: eventsModelController.getEventsForDateComponents(dateComponents))
        }
        
        // Dismiss the subview if requested
        if shouldDismissSubview {
            navigationController?.popViewController(animated: true)
        }
    }    
}
