//
//  HomeNavigationController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 12/05/2023.
//

import UIKit

class HomeNavigationController: UINavigationController {
    weak var eventsModelController: EventsModelController?
    weak var userModelController: UserModelController?
    weak var tribeModelController: TribeModelController?

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let calendarViewController = segue.destination as? CalendarViewController {
            calendarViewController.eventsModelController = eventsModelController
        }
    }
}

// MARK: Private extensions
extension HomeNavigationController {
    func initialize() {
        if let homeViewController = self.viewControllers[0] as? HomeViewController {
            homeViewController.eventsModelController = eventsModelController
            homeViewController.userModelController = userModelController
            homeViewController.tribeModelController = tribeModelController
            
            navigationBar.tintColor = .systemIndigo
        }
    }
 }
