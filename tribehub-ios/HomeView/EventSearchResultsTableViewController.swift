//
//  EventSearchResultsTableViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 30/06/2023.
//

import UIKit

// MARK: UITableViewCell subclass definitions
class SearchTokenTableViewCell: UITableViewCell {
    @IBOutlet weak var searchTokenLabel: UILabel!
}

class EventSearchResultTableViewCell: UITableViewCell {
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
}


// MARK: EventSearchResultsTableViewControllerDelegate protocol definition
protocol EventSearchResultsTableViewControllerDelegate {
    func didSelectToken(_ token: UISearchToken)
    func doEventsSearch()
}

// MARK: EventSearchResultsTableViewController class definition
class EventSearchResultsTableViewController: UITableViewController {
    weak var userModelController: UserModelController?
    weak var eventsModelController: EventsModelController?
    weak var tribeModelController: TribeModelController?
    weak var homeViewController: HomeViewController?
    
    var delegate: EventSearchResultsTableViewControllerDelegate?
    
    private var selectedScopeButtonIndex: Int?
    
    // Holds search tokens corresponding with potential selections of
    // tribe members and event categories. Used to populate table with a list
    // of potential selections.
    private var searchTokens: [UISearchToken]?
    
    // Used to record whether search results are currently being displayed.
    // If false, then the table is displaying a list of search tokens (tribe members or
    // event categories) from which the user could pick.
    private var isDisplayingSearchResults = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // No actions required here at the moment. Could delete override.
    }
 
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // If we're not displaying search results, then we must be displaying a list of search tokens the
        // user could add, so return the number of searchtokens.
        if !isDisplayingSearchResults {
            if let searchTokens = searchTokens {
                return searchTokens.count
            }
        }
        
        // Otherwise, return the number of events found by the search
        if let eventsCount = eventsModelController?.events?.results.count {
            return eventsCount
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // If we're not displaying search results, then configure and return a cell to represent
        // the relevant search token.
        if !isDisplayingSearchResults {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTokenCell", for: indexPath) as! SearchTokenTableViewCell
            if let searchTokens = searchTokens {
                if let tribeMemberName = (searchTokens[indexPath.row].representedObject as? TribeMember)?.displayName {
                    cell.searchTokenLabel.text = tribeMemberName
                }
                if let categoryName = (searchTokens[indexPath.row].representedObject as? EventCategories)?.text {
                    cell.searchTokenLabel.text = categoryName
                }
            }
            return cell
        } else {
            // Otherwise, configure and return a cell to represent an event
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventSearchResultCell", for: indexPath) as! EventSearchResultTableViewCell
            guard let event = eventsModelController?.events?.results[indexPath.row] else { return cell }
            // Get the appropriate icon for the event category
            if let category = EventCategories(rawValue: event.category ?? "NON") {
                cell.categoryImage.image = category.image.withRenderingMode(.alwaysTemplate)
                cell.categoryImage.tintColor = UIColor(named: "THAccent")
            }
            
            if let subject = event.subject {
                cell.subjectLabel.text = subject
            }
            
            // Calculate end date from start date and duration, use date formatter to
            // extract only a time string for the start and end dates, and set the text
            // on the timeLabel.
            if let startDate = event.start {
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = .gmt
                dateFormatter.locale = Locale(identifier: "en_GB")
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .none
                let start = dateFormatter.string(from: startDate)
                cell.timeLabel.text = "\(start)"
            }
            
            // Align separator with right of category icon
            cell.separatorInset = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 0)
            return cell
        }
    }
    
    /// Handles selection of tableViewCell if user selected a cell representing a searchToken option, by
    /// calling didSelectToken(token) on the delegate.
    /// If the cell represents an event from the search results, then it'll be handled by a storyboard segue instead.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let token = searchTokens?[indexPath.row] {
            delegate?.didSelectToken(token)
        }
    }

    // MARK: - Navigation
    /// Handles the segue to the CalEventsDetailsViewController, to display details of a specific event from the search results.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let events = eventsModelController?.events?.results else { return }
        
        // Find the row of the selected cell, and pass the corresponding event to the child viewController
        if let calEventDetailsViewController = segue.destination as? CalEventDetailsViewController {
            calEventDetailsViewController.userModelController = userModelController
            calEventDetailsViewController.tribeModelController = tribeModelController
            calEventDetailsViewController.eventsModelController = eventsModelController
            calEventDetailsViewController.delegate = self
            calEventDetailsViewController.calEventDetailsTableViewControllerDelegate = self
            if let selectedCell = sender as? EventSearchResultTableViewCell {
                let cellRow = tableView.indexPath(for: selectedCell)?.row ?? 0
                calEventDetailsViewController.event = events[cellRow]
            }
        }
    }
}

// MARK: public extension
extension EventSearchResultsTableViewController {
    
    /// Handles a change to the scope button selection by storing the selected index, storing
    /// the search tokens that are passed in and reloading the tableview data
    func scopeButtonSelectionDidChangeToIndex(_ index: Int, withSearchTokens searchTokens: [UISearchToken]?) {
        selectedScopeButtonIndex = index
        if (1...2).contains(index) {
            isDisplayingSearchResults = false
        } else {
            isDisplayingSearchResults = true
        }
        self.searchTokens = searchTokens
        tableView.reloadData()
    }
    
    func searchResultsDidUpdate() {
        tableView.reloadData()
    }
}

// MARK: CalEventDetailsViewControllerDelegate, CalEventDetailsTableViewControllerDelegate extension
extension EventSearchResultsTableViewController: CalEventDetailsViewControllerDelegate, CalEventDetailsTableViewControllerDelegate {
    /// Asks the delegate to fetch the search results from the API in the event an event was edited or deleted by the user while viewing
    /// search results. Currently, this method will never be called, since the detail of events from the search results is presented modally,
    /// with no edit button due to the lack of navigation items. This method is a requirement of these protocols, and the ability to edit
    /// from the search results view may be added in future, so have left in for now.
    func calEventDetailsDidChange(shouldDismissSubview: Bool, event: Event?) async throws {
        delegate?.doEventsSearch()
    }
}

