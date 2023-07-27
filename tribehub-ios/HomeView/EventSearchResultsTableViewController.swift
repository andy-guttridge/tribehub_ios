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
    private var searchTokens: [UISearchToken]?
    
    private var isDisplayingSearchResults = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initialize()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !isDisplayingSearchResults {
            if let searchTokens = searchTokens {
                return searchTokens.count
            }
        }
        
        if let eventsCount = eventsModelController?.events?.results.count {
            return eventsCount
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            if let startDate = event.start, let duration = event.duration {
                let endDate = Date(timeInterval: duration, since: startDate)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let token = searchTokens?[indexPath.row] {
            delegate?.didSelectToken(token)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation
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

// MARK: private extension
private extension EventSearchResultsTableViewController {
    func initialize() {
        if searchTokens != nil {
            
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
    func calEventDetailsDidChange(shouldDismissSubview: Bool, event: Event?) async throws {
        delegate?.doEventsSearch()
    }
}

