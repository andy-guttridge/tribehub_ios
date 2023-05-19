//
//  HomeNavigationController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 12/05/2023.
//

import UIKit

class HomeNavigationController: UINavigationController {
    var eventsModelController: EventsModelController?
    var tribeModelController: TribeModelController?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let homeViewController = self.viewControllers[0] as? HomeViewController {
            homeViewController.eventsModelController = eventsModelController
            homeViewController.tribeModelController = tribeModelController
        }
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let calendarViewController = segue.destination as? CalendarViewController {
            calendarViewController.eventsModelController = eventsModelController
        }
    }
}
