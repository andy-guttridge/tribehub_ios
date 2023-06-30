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
    weak var homeViewController: HomeViewController?

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
private extension HomeNavigationController {
    func initialize() {
        if let homeViewController = self.viewControllers[0] as? HomeViewController {
            homeViewController.eventsModelController = eventsModelController
            homeViewController.userModelController = userModelController
            homeViewController.tribeModelController = tribeModelController
            self.homeViewController = homeViewController
            
            // Configure searchController
            // Get a reference to the tableView for presenting search results and use it to instantiate a searchController
            if let eventSearchResultsTableView = storyboard?.instantiateViewController(withIdentifier: "EventSearchTableViewController") as? EventSearchResultsTableViewController {
                navigationBar.topItem?.searchController = UISearchController.init(searchResultsController: eventSearchResultsTableView)
                navigationBar.topItem?.searchController?.searchBar.delegate = eventSearchResultsTableView
                eventSearchResultsTableView.tribeModelController = tribeModelController
                eventSearchResultsTableView.eventsModelController = eventsModelController
            }
            navigationBar.topItem?.searchController?.delegate = self
            navigationBar.topItem?.preferredSearchBarPlacement = .inline
            navigationBar.topItem?.searchController?.scopeBarActivation = .onSearchActivation
            navigationBar.topItem?.searchController?.searchBar.scopeButtonTitles = ["Subject", "Tribe", "Category", "From", "To"]
            
            // Configure navigation bar
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.backgroundColor = UIColor(named: "THBackground")
            navigationBar.tintColor = UIColor(named: "THIcons")
            navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Fredoka-Bold", size: 20)!]
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Nunito-SemiBold", size: 18)!], for: .normal)
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Nunito-SemiBold", size: 18)!], for: .highlighted)
        }
    }
 }

// MARK: UISearchControllerDelegate
extension HomeNavigationController: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        print("SearchController was dismissed")
    }
}
