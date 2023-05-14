//
//  CalendarViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 12/05/2023.
//

import UIKit

class CalendarViewController: UIViewController {
    
    var calendarView: UICalendarView?
    var eventsModelController: EventsModelController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task.init {
            do {
                // Fetch events from the backend and refresh calendar decorations
                try await self.eventsModelController?.getEvents()
                refreshCalDecorationsForCurrentMonth()
            } catch {
                print("Error fetching events")
            }
        }
    }
}

// MARK: private extensions
private extension CalendarViewController {

    /// Creates and sets up a UICalendarView and adds it as a sub-view
    func initialize() {
        
        // Create and configure a UICalendarView
        calendarView = UICalendarView()
        let gregorianCalendar = Calendar(identifier: .gregorian)
        calendarView!.calendar = gregorianCalendar
        calendarView!.locale = Locale(identifier: "en")
        calendarView!.fontDesign = .rounded
        calendarView!.visibleDateComponents = gregorianCalendar.dateComponents([.year, .month, .day], from: Date())
        calendarView!.tintColor = .systemPink
        
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
    }
    
    /// Checks whether there are any events for a given date
    func checkEventsForDateComponents(_ dateComponents: DateComponents) -> Bool? {
        guard let events = eventsModelController?.events?.results else { return nil }
        
        // Convert date components produced by the calendar to a date object
        let calendarDate = calendarView?.calendar.date(from: dateComponents)
        
        // Reduce the array of events to a single bool to indicate whether there are any events on the given date
        let dayHasEvents: Bool = events.reduce(false) { acc, event in
            guard let eventDate = event.start else {return acc || false}
            
            // Convert the event to a date with no time data
            let calendar = Calendar(identifier: .gregorian)
            let eventComponents = calendar.dateComponents([.day, .month, .year], from: eventDate)
            let eventDateWithNoTime = calendar.date(from: eventComponents)
            
            // Check whether the event date and the date from the calendar match, and OR with the accumulator
            // to ensure we return true if we've previously found a match, even if we didn't this time
            
            return acc || eventDateWithNoTime == calendarDate
        }
        return dayHasEvents
    }
    
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
        
        // Create a date object from the components of the selected date
        let selectedDate = calendarView?.calendar.date(from: dateComponents)
        print(selectedDate)
    }
}

// MARK: UICalendarViewDelegate extension
extension CalendarViewController: UICalendarViewDelegate {
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        if let dateHasEvents = checkEventsForDateComponents(dateComponents) {
            if dateHasEvents {
                return UICalendarView.Decoration.default(color: .systemIndigo, size: .large)
            }
        }
        return nil
    }
}
