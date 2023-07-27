//
//  CalendarViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 12/05/2023.
//

import UIKit


/// Defines delegate method to handle the user selecting a different date on the calendar
protocol CalendarViewControllerDelegate {
    func didSelectCalendarDate(_ dateComponents: DateComponents)
}

class CalendarViewController: UIViewController {
    
    var calendarView: UICalendarView?
    var eventsModelController: EventsModelController?
    var delegate: CalendarViewControllerDelegate?
    
    // Property to store date range for fetching calendar data
    var selectedDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshDataAndCalendar()
    }
}

// MARK: private extensions
private extension CalendarViewController {
    
    /// Creates and sets up a UICalendarView and adds it as a sub-view
    func initialize() {
        
        // Create and configure a UICalendarView
        calendarView = UICalendarView()
        calendarView!.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        calendarView!.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        let gregorianCalendar = Calendar(identifier: .gregorian)
        calendarView!.calendar = gregorianCalendar
        calendarView!.locale = Locale(identifier: "en")
        calendarView!.fontDesign = .rounded
        calendarView!.visibleDateComponents = gregorianCalendar.dateComponents([.year, .month, .day], from: Date())
        calendarView!.tintColor = UIColor(named: "THHighlight")
        
        // Set calendar autolayout constraints so it's the same size as the container view and add as a subview
        calendarView!.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(calendarView!)
        NSLayoutConstraint.activate([
            calendarView!.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarView!.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarView!.topAnchor.constraint(equalTo: view.topAnchor),
            calendarView!.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Configure calendar for single date selection and set self as delegate
        calendarView?.selectionBehavior = UICalendarSelectionSingleDate(delegate: self)
        calendarView?.delegate = self
        print(calendarView?.frame)
    }
    
    /// Uses the stored selectedDate to calculate and return a fromDate one month before selected date
    /// and a toDate three months after the selected date
    func calcToAndFromDates() -> (toDate: Date, fromDate: Date) {
        // Calculate start and end dates 1 month before and 3 months after today
        let calendar = Calendar(identifier: .gregorian)
        var dateComponents = DateComponents()
        dateComponents.month = -1
        let fromDate = calendar.date(byAdding: dateComponents, to: selectedDate ?? Date())
        dateComponents.month = 3
        let toDate = calendar.date(byAdding: dateComponents, to: selectedDate ?? Date())
        return (toDate: toDate ?? Date(), fromDate: fromDate ?? Date())
    }
    
    /// Requests fresh events data from the API and  refreshes the calendar decorations
    func refreshDataAndCalendar() {
        Task.init {
            do {
                // Calculate start and end dates 1 month before and 4 months after today
                let toFromDates = calcToAndFromDates()
                
                // Fetch events from the backend and refresh calendar decorations
                try await self.eventsModelController?.getEvents(fromDate: toFromDates.fromDate, toDate: toFromDates.toDate)
                refreshCalDecorationsForCurrentMonth()
            } catch HTTPError.badRequest(let apiResponse) {
                self.dismiss(animated: true, completion: nil)
                let errorMessage = apiResponse
                let errorAlert = makeErrorAlert(title: "Error fetching calendar events", message: "There was an issue fetching calendar events.\n\nThe server reported an error: \n\n\(errorMessage)")
                self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
            } catch HTTPError.otherError(let statusCode) {
                self.dismiss(animated: true, completion: nil)
                let errorAlert = makeErrorAlert(title: "Error fetching calendar events", message: "There was an issue fetching calendar events.\n\nThe status code reported by the server was \(statusCode).")
                self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
            } catch {
                self.dismiss(animated: true, completion: nil)
                let errorAlert = makeErrorAlert(title: "Error fetching calendar events", message: "There was an issue fetching calendar events.\n\nPlease check you are online.")
                self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
            }
        }
    }
}

// MARK: Public extension
extension CalendarViewController {
    /// Refreshes calendar decorations for all days in month currently visible on the calendar
    func refreshCalDecorationsForCurrentMonth() {
        guard let calendarView = calendarView else { return }
        
        // Get the date currently visible on the calendar from dateComponents it supplies, and extract the month and year
        let calendar = calendarView.calendar
        let currentVisibleDate = calendar.date(from: calendarView.visibleDateComponents)
        let year = calendarView.visibleDateComponents.year
        let month = calendarView.visibleDateComponents.month
        
        // Use calendar.range() to get a date object for each day in the month of the currently visible calendar date,
        // and map to create an array of dateComponents object for each day of the displayed month and year, and use these to
        // ask the calendarView to refresh the calendar decorations for each day in the current month.
        // Technique for getting each day of the month is from
        // https://stackoverflow.com/questions/63973204/how-can-we-get-all-the-days-in-selected-month
        if let date = currentVisibleDate {
            let dateComponentsForMonthDays = calendar.range(of: .day, in: .month, for: date)?.compactMap {
                DateComponents(calendar: calendar, year: year, month: month, day: $0, hour: 0)
            } ?? []
            calendarView.reloadDecorations(forDateComponents: dateComponentsForMonthDays, animated: true)
        }
    }
}

// MARK: UICalendarSelectionSingleDateDelegate extension
extension CalendarViewController: UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let dateComponents = dateComponents else { return }
        delegate?.didSelectCalendarDate(dateComponents)
    }
}

// MARK: UICalendarViewDelegate extension
extension CalendarViewController: UICalendarViewDelegate {
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        guard let eventsModelController = eventsModelController else {return nil}
        
        // Check if there are any events for the date the calendar is asking about, and return a decoration if there are
        if let dateHasEvents = eventsModelController.checkEventsForDateComponents(dateComponents) {
            if dateHasEvents {
                return UICalendarView.Decoration.default(color: UIColor(named: "THAccent"), size: .large)
            }
        }
        return nil
    }
    
    /// Sets the selectedDate and refreshes the events data from the API and the calendar decorations
    /// in response to the user changing the visible dates
    func calendarView(_ calendarView:UICalendarView, didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents) {
        selectedDate = calendarView.calendar.date(from: calendarView.visibleDateComponents)
        refreshDataAndCalendar()
    }
}
