//
//  CalEventTableViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 18/05/2023.
//

import UIKit

class CalEventCell: UITableViewCell {
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
}

class CalEventTableViewController: UITableViewController {
    private var events: [Event]?
    weak var userModelController: UserModelController?
    weak var tribeModelController: TribeModelController?
    weak var eventsModelController: EventsModelController?
    
    weak var calEventDetailsTableViewControllerDelegate: HomeViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events?.count ?? 0
    }
    
    /// Responds to a change in currently selected events by reloading the tableView data
    func eventsDidChange(events: [Event]?) {
        self.events = events
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalEventCell", for: indexPath) as! CalEventCell
        guard let event = events?[indexPath.row] else { return cell }
        
        // Get the appropriate icon for the event category
        if let category = EventCategories(rawValue: event.category ?? "NON") {
            cell.categoryImage.image = category.image.withRenderingMode(.alwaysTemplate)
            cell.categoryImage.tintColor = UIColor(named: "THIcons")
        }
        
        // Set the event subject text
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
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            let startTime = dateFormatter.string(from: startDate)
            let endTime = dateFormatter.string(from: endDate)
            cell.timeLabel.text = "\(startTime) - \(endTime)"
        }
        
        // Align separator with right of category icon
        cell.separatorInset = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 0)
        return cell
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
        guard let events = events else { return }
        
        // Find the row of the selected cell, and pass the corresponding event to the child viewController
        if let calEventDetailsViewController = segue.destination as? CalEventDetailsViewController {
            calEventDetailsViewController.userModelController = userModelController
            calEventDetailsViewController.tribeModelController = tribeModelController
            calEventDetailsViewController.eventsModelController = eventsModelController
            if let homeViewController = parent as? HomeViewController {
                calEventDetailsViewController.delegate = homeViewController
            }
            calEventDetailsViewController.calEventDetailsTableViewControllerDelegate = calEventDetailsTableViewControllerDelegate
            if let selectedCell = sender as? CalEventCell{
                let cellRow = tableView.indexPath(for: selectedCell)?.row ?? 0
                calEventDetailsViewController.event = events[cellRow]
            }
        }
    }
}
