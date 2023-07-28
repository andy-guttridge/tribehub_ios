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
    
    // Holds the currently selected calendar date
    private var currentlySelectedDate: Date?
    
    // Holds the currently selected searchbar scope
    private var currentlySelectedScope: Int? = 0;
    
    // Holds a timer used to delay fetching search results while user types into search bar
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    // MARK: - Navigation
    /// Handles the segue to the EventFormTableViewController, in the event the user selects to add a
    /// a new event
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let eventFormTableViewController = segue.destination as? EventFormTableViewController {
            eventFormTableViewController.userModelController = userModelController
            eventFormTableViewController.tribeModelController = tribeModelController
            eventFormTableViewController.eventsModelController = eventsModelController
            eventFormTableViewController.delegate = self
            
            // Passing the currentlySelectedDate enables the eventsFormTableViewController to
            // set the initial value for the datePicker for a new event
            eventFormTableViewController.shouldStartEditingWithDate = currentlySelectedDate
        }
    }
}

// MARK: private extensions
private extension HomeViewController {
    /// Initialises the HomeViewController
    func initialize() {
        // Pass required references to child view controllers
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
        
        // Get a reference to the tableView for presenting search results and use it to instantiate a searchController
        if let eventSearchResultsTableViewController = storyboard?.instantiateViewController(withIdentifier: "EventSearchTableViewController") as? EventSearchResultsTableViewController {
            navigationItem.searchController = UISearchController.init(searchResultsController: eventSearchResultsTableViewController)
            
            // Pass reqyured references to searchResultsController
            eventSearchResultsTableViewController.userModelController = userModelController
            eventSearchResultsTableViewController.tribeModelController = tribeModelController
            eventSearchResultsTableViewController.eventsModelController = eventsModelController
            eventSearchResultsTableViewController.delegate = self
        }
        
        // Configure searchController and searchBar.
        navigationItem.preferredSearchBarPlacement = .stacked
        navigationItem.searchController?.searchBar.delegate = self
        navigationItem.searchController?.searchResultsUpdater = self
        navigationItem.searchController?.searchBar.searchTextField.tokenBackgroundColor = UIColor(named: "THHighlight")
        navigationItem.searchController?.scopeBarActivation = .onSearchActivation
        navigationItem.searchController?.searchBar.scopeButtonTitles = ["Subject", "Tribe", "Category", "From", "To"]
        
        // Configure rightBarButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addEvent))
    }
    
    /// Responds to user selecting to add a new calendar event by seguing to EventFormTableViewController
    @objc func addEvent() {
        performSegue(withIdentifier: "EventFormSegue", sender: self)
    }
    
    /// Create search tokens for either the user's tribe  members or event categories
    /// based on the currently  selected scope button value
    func makeSearchTokens() -> [UISearchToken]? {
        
        // Create search tokens for user's tribe members if scope button 1 selected
        if currentlySelectedScope == 1 {
            let searchTokens = tribeModelController?.tribe?.tribeMembers.map() {tribeMember in
                let token = UISearchToken(icon: nil, text: tribeMember.displayName ?? "")
                token.representedObject = tribeMember
                return token
            }
            return searchTokens
        }
        
        // Create search tokens for event categories if scope button 2 selected
        if currentlySelectedScope == 2 {
            var searchTokens: [UISearchToken] = []
            for eventCategory in EventCategories.allCases {
                let token = UISearchToken(icon: nil, text: eventCategory.text)
                token.representedObject = eventCategory
                searchTokens.append(token)
            }
            return searchTokens
        }
        return nil
    }
    
    /// Handle user picking a to or from search date
    @objc func didPickToOrFromSearchDate(sender: UIDatePicker) {
        var fromDateTokenIndex: Int? = nil
        var toDateTokenIndex: Int? = nil
        
        var fromDate: Date? = nil
        var toDate: Date? = nil
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        
        // Find out if user already has to and from date searchTokens in the searchbar,
        // and find their indices in the searchTokens array, and the dates they represent.
        // Have to use a brute force technique to check all the searchTokens, as the API
        // doesn't provide a way to be notified when the user removes a searchToken.
        if let searchTokens = navigationItem.searchController?.searchBar.searchTextField.tokens {
            searchTokens.enumerated().forEach {(index, searchToken) in
                if let representedObject = searchToken.representedObject as? Dictionary<String, Any> {
                    if representedObject["from"] != nil {
                        fromDateTokenIndex = index
                        if let dateStr = representedObject["from"] as? String {
                            fromDate = dateFormatter.date(from: dateStr)
                        }
                    }
                    if representedObject["to"] != nil {
                        toDateTokenIndex = index
                        if let dateStr = representedObject["to"] as? String {
                            toDate = dateFormatter.date(from: dateStr)
                        }
                    }
                }
            }
        }

        var tokenText = ""
        
        // Create a new search token for a fromDate and add to searchBar, if the user
        // has selected scope button 3 and there is not already a toDate with a value less than the
        // fromDate the user has selected (don't want to allow user to enter a fromDate
        // which is after the toDate).
        if currentlySelectedScope == 3 && (toDate ?? sender.date >= sender.date) {
            tokenText = "From: \(dateFormatter.string(from: sender.date))"
            let token = UISearchToken(icon: nil, text: tokenText)
            token.representedObject = ["from": dateFormatter.string(from: sender.date)]
            if let searchTextField = navigationItem.searchController?.searchBar.searchTextField {
                searchTextField.insertToken(token, at: searchTextField.tokens.count)
                setSearchTimer()
                if let tokenIndex = fromDateTokenIndex {
                    searchTextField.removeToken(at: tokenIndex)
                }
            }
        } else if currentlySelectedScope == 4 && (fromDate ?? sender.date <= sender.date) {
            // Otherwise, if the user has selected scopeButton 4 and there is no fromDate with a
            // date after the selected toDate, create a toDate search token and add to searchBar
            tokenText = "To: \(dateFormatter.string(from: sender.date))"
            let token = UISearchToken(icon: nil, text: tokenText)
            token.representedObject = ["to": dateFormatter.string(from: sender.date)]
            if let searchTextField = navigationItem.searchController?.searchBar.searchTextField {
                searchTextField.insertToken(token, at: searchTextField.tokens.count)
                setSearchTimer()
                if let tokenIndex = toDateTokenIndex {
                    searchTextField.removeToken(at: tokenIndex)
                }
            }
        }
    }
    
    /// Sets a one second timer to delay fetching search results until after user
    /// has stopped entering data into the searchBar
    func setSearchTimer() {
        // Cancel any timers already running
        if let timer = timer {
            timer.invalidate()
        }
        
        // Set a one second timer to delay fetching search results until user has finished typing, and store search text
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(doEventsSearch), userInfo: nil, repeats: false)
    }
    

}

// MARK: CalendarViewControllerDelegate extension
extension HomeViewController: CalendarViewControllerDelegate {
    /// Handes user selecting a date on the calendar
    func didSelectCalendarDate(_ dateComponents: DateComponents) {
        guard let eventsModelController = eventsModelController else { return }
        calendarTableViewController?.eventsDidChange(events: eventsModelController.getEventsForDateComponents(dateComponents))
        
        // Create copy of dateComponents with a time component and timezone, and store.
        // This date is used by EventFormTableViewController to set a default date for a new event
        // based on the selected calendar date.
        var dateComponentsWithTime = dateComponents
        dateComponentsWithTime.hour = 12
        dateComponentsWithTime.timeZone = .gmt
        
        // Set the currentlySelectedDate in this view controller and also in the calendarViewController
        currentlySelectedDate = calendarViewController?.calendarView?.calendar.date(from: dateComponentsWithTime)
        calendarViewController?.selectedDate = (calendarViewController?.calendarView?.calendar.date(from: dateComponentsWithTime))
    }
}

// MARK: CalEventDetailsTableViewControllerDelegate, EventFormTableViewControllerDelegate, CalEventDetailsViewController extension
extension HomeViewController: CalEventDetailsTableViewControllerDelegate, EventFormTableViewControllerDelegate, CalEventDetailsViewControllerDelegate {
    
    /// Fetches fresh events data from the API, reloads data for the calendarTableView and refreshes calendar decorations
    /// - shouldDismissSubview: Bool - tells the function whether the view of the view controller that called this delegate method should be dismissed
    /// - event: Event? - optionally provides this method with details of an existing event whose details have been edited
    func calEventDetailsDidChange(shouldDismissSubview: Bool, event: Event?) async throws {
        guard let eventsModelController = eventsModelController, let calendarViewController = calendarViewController, let calEventTableViewController = self.children[1] as? CalEventTableViewController else { return }
        
        try await eventsModelController.getEvents()
        calendarTableViewController?.tableView.reloadData()
        calendarViewController.refreshCalDecorationsForCurrentMonth()
        
        // If an existing event has been passed in, that means the user has edited an event or it has been deleted,
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

// MARK: UISearchBarDelegate
extension HomeViewController: UISearchBarDelegate {
    /// Handles selection of scope buttons in searchBar
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        guard let searchResultsController = navigationItem.searchController?.searchResultsController as? EventSearchResultsTableViewController else { return }
        currentlySelectedScope = selectedScope
        
        if (1...2).contains(selectedScope) {
            // If user has selected the Tribe or Category scope buttons, create the relevant search tokens,
            // tell the searchResultsController that the scope was changed, pass it the relevant search tokens
            // and set the correct inputView for the searchTextField
            
            let searchTokens = makeSearchTokens()
            searchResultsController.scopeButtonSelectionDidChangeToIndex(selectedScope, withSearchTokens: searchTokens)
            navigationItem.searchController?.searchBar.searchTextField.resignFirstResponder()
            navigationItem.searchController?.searchBar.searchTextField.inputView = nil
            navigationItem.searchController?.searchBar.searchTextField.becomeFirstResponder()
        }
        else if (3...4).contains(selectedScope) {
            // If user has selected the From date or To date scope buttons, create and configure a date picker,
            // use this as the inputView for the searchTextField and inform the searchResultsController that the
            // scope button selection was changed
            
            let datePicker = UIDatePicker(frame: .zero)
            datePicker.datePickerMode = .date
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.addTarget(self, action: #selector(didPickToOrFromSearchDate(sender:)), for: .valueChanged)
            navigationItem.searchController?.searchBar.searchTextField.inputView = datePicker
            navigationItem.searchController?.searchBar.searchTextField.resignFirstResponder()
            searchResultsController.scopeButtonSelectionDidChangeToIndex(selectedScope, withSearchTokens: nil)
            navigationItem.searchController?.searchBar.searchTextField.becomeFirstResponder()
        } else {
            // Otherwise, make sure a standard input keyboard is available and tell the searchResults controller
            // the scope button selection changed
            searchResultsController.scopeButtonSelectionDidChangeToIndex(selectedScope, withSearchTokens: nil)
            navigationItem.searchController?.searchBar.searchTextField.resignFirstResponder()
            navigationItem.searchController?.searchBar.searchTextField.inputView = nil
            navigationItem.searchController?.searchBar.searchTextField.becomeFirstResponder()
        }
    }
    
    /// Sets off the searchTimer if user changes contents of searchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        setSearchTimer()
    }
}

// MARK: UISearchResultsUpdating
extension HomeViewController: UISearchResultsUpdating {
    /// Ensures the searchController show the searchResultsController
    func updateSearchResults(for searchController: UISearchController) {
        searchController.showsSearchResultsController = true
    }
}

// MARK: EventSearchResultsTableViewControllerDelegate
extension HomeViewController: EventSearchResultsTableViewControllerDelegate {
    
    /// Adds a searchToken to the searchTextField for the corresponding option selected by the user
    func didSelectToken(_ token: UISearchToken) {
        // Check if the selected token is a category token...
        if token.representedObject is EventCategories {
            //... and if so remove any other category tokens
            // before adding this one, as the API can only search on one category at a time
            
            if let tokens = navigationItem.searchController?.searchBar.searchTextField.tokens {
                tokens.enumerated().forEach {(index, aToken) in
                    if aToken.representedObject is EventCategories {
                        navigationItem.searchController?.searchBar.searchTextField.removeToken(at: index)
                    }
                }
            }
        }
        
        if let searchTextField = navigationItem.searchController?.searchBar.searchTextField, let searchBar = navigationItem.searchController?.searchBar {
            searchTextField.insertToken(token, at: searchTextField.tokens.count)
            
            // Set selected scope button index to zero and let searchDisplayController know,
            // so that it resets back to the 'Subject' scope button
            searchBar.selectedScopeButtonIndex = 0
            if let searchDisplayController = navigationItem.searchController?.searchResultsController as? EventSearchResultsTableViewController {
                searchDisplayController.scopeButtonSelectionDidChangeToIndex(0, withSearchTokens: nil)
            }
            setSearchTimer()
        }
    }
    
    /// Requests search results from the API
    @objc func doEventsSearch() {
        let searchText = navigationItem.searchController?.searchBar.searchTextField.text
        var searchCategory: String?
        var tribe: [Int]?
        var fromDate: Date?
        var toDate: Date?
        
        // Retrieves any searchTokens from the searchBar, and creates the corresponding
        // data to form url parameters for the API
        if let searchTokens = navigationItem.searchController?.searchBar.searchTextField.tokens {
            for searchToken in searchTokens {
                if let tribeMember = searchToken.representedObject as? TribeMember {
                    if tribe == nil {
                        tribe = []
                    }
                    tribe?.append(tribeMember.pk ?? 0)
                }
                if let category = searchToken.representedObject as? EventCategories {
                    searchCategory=category.rawValue
                }
                if let dateTokenDict = searchToken.representedObject as? Dictionary<String, String> {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd MMM yyyy"
                    if dateTokenDict["from"] != nil {
                        fromDate = dateFormatter.date(from: dateTokenDict["from"] ?? dateFormatter.string(from: Date()))
                    }
                    if dateTokenDict["to"] != nil {
                        toDate = dateFormatter.date(from: dateTokenDict["to"] ?? dateFormatter.string(from: Date()))
                    }
                }
            }
        }
        
        // Ask the eventsModelController to request the required data from the API
        Task.init {
            do {
                try await eventsModelController?.getEvents(
                    fromDate: fromDate,
                    toDate: toDate,
                    searchText: searchText,
                    category: searchCategory,
                    tribeMembers: tribe)
                if let searchDisplayController = navigationItem.searchController?.searchResultsController as? EventSearchResultsTableViewController as? EventSearchResultsTableViewController {
                    searchDisplayController.searchResultsDidUpdate()
                }
            } catch HTTPError.badRequest(let apiResponse) {
                self.dismiss(animated: true, completion: nil)
                let errorMessage = apiResponse
                let errorAlert = makeErrorAlert(title: "Error fetching search results", message: "The server reported an error: \n\n\(errorMessage)")
                self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
            } catch HTTPError.otherError(let statusCode) {
                self.dismiss(animated: true, completion: nil)
                let errorAlert = makeErrorAlert(title: "Error fetching search results", message: "The status code reported by the server was \(statusCode)")
                self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
            } catch {
                self.dismiss(animated: true, completion: nil)
                let errorAlert = makeErrorAlert(title: "Error fetching search results", message: "Something went wrong. Please check you are online.")
                self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
            }
        }
    }
}
