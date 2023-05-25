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
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
    }
}

// MARK: CalendarViewControllerDelegate extension
extension HomeViewController: CalendarViewControllerDelegate {
    func didSelectCalendarDate(_ dateComponents: DateComponents) {
        guard let eventsModelController = eventsModelController else { return }
        calendarTableViewController?.eventsDidChange(events: eventsModelController.getEventsForDateComponents(dateComponents))
    }
}

// MARK: CalEventDetailsTableViewControllerDelegate extension
extension HomeViewController: CalEventDetailsTableViewControllerDelegate {
    
    /// Fetches fresh events data from the API, reloads data for the calendarTableView and refreshes calendar decorations
    func calEventDetailsDidChange() async throws {
        print("Refresh events!")
        guard let eventsModelController = eventsModelController, let calendarViewController = calendarViewController else { return }
        try await eventsModelController.getEvents()
        calendarTableViewController?.tableView.reloadData()
        calendarViewController.refreshCalDecorationsForCurrentMonth()
    }    
}
