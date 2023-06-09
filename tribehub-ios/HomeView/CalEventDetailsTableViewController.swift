//
//  CalEventDetailsTableViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 19/05/2023.
//

import UIKit

// MARK: custom cell class definitions
class EventTitleCell: UITableViewCell {
    @IBOutlet weak var titleCategoryImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
}

class EventDateCell: UITableViewCell {
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var repeatIcon: UIImageView!
}

class EventAttendeeCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
}

class EventResponseCell: UITableViewCell {
    @IBOutlet weak var responseSegmentedControl: UISegmentedControl!
}

// MARK: CalEventDetailsTableViewControllerDelegate protocol definition
protocol CalEventDetailsTableViewControllerDelegate {
    func calEventDetailsDidChange(shouldDismissSubview: Bool, event: Event?) async throws
}

// MARK: CalEventDetailsTableViewController defintion
class CalEventDetailsTableViewController: UITableViewController {
    weak var userModelController: UserModelController?
    weak var tribeModelController: TribeModelController?
    weak var eventsModelController: EventsModelController?
    
    var delegate: CalEventDetailsTableViewControllerDelegate?
    var event: Event?
    
    private var isInvited: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            // We definitely need at least 2 rows for section 0 for event category and title, start and end times
            var numRows = 2
            
            // Add another row if user has been invited to this event as will need to display the not going/going segmentedControl
            if let toUsers = event?.to {
                if toUsers.contains(where: { user in
                    return userModelController?.user?.pk == user.pk
                }) {
                    numRows += 1
                    isInvited = true
                }
            }
            return numRows
        }
       
        // Otherwise it must be section 1. Start with one row for the event owner
        var numRows = 1
        if let numInvited = event?.to?.count {
            numRows += numInvited
        }
        return numRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let event = event else { return tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)}
        
        // Section 0, row 0 is category icon and subject
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventTitleCell", for: indexPath) as! EventTitleCell
            if let category = event.category {
                cell.titleCategoryImage.image = EventCategories(rawValue: category)?.image.withRenderingMode(.alwaysTemplate)
                cell.titleCategoryImage.tintColor = UIColor(named: "THAccent")
            }
            cell.titleLabel.text = event.subject
            
            // Approach to using numberOfLines and sizeToFit to cause the cell to size itself to fit its content is from
            // https://stackoverflow.com/questions/5430890/uilabel-auto-resize-on-basis-of-text-to-be-shown
            cell.titleLabel.numberOfLines = 0
            cell.titleLabel.sizeToFit()
            cell.layoutMargins = UIEdgeInsets.zero
            
            // Hide cell separator. Technique for doing this is from
            // https://stackoverflow.com/questions/66324664/remove-first-line-separator-of-uitableview-cells
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            return cell
        }
        
        // Section 0, row 1 is start and end dates/times
        if indexPath.section == 0 && indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventDateCell", for: indexPath) as! EventDateCell
            if let startDate = event.start, let duration = event.duration {
                
                // Use date formatter to extract time and date strings from event start and end date.
                // We have to calculate the end date from the start date and duration
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = .gmt
                dateFormatter.timeStyle = .short
                dateFormatter.dateStyle = .medium
                dateFormatter.locale = Locale(identifier: "en_GB")
                let startString = dateFormatter.string(from: startDate)
                let endDate = Date(timeInterval: duration, since: startDate)
                let endString = dateFormatter.string(from: endDate)
                
                // Add start and end date strings to label text
                cell.startDateLabel.text = startString
                cell.endDateLabel.text = endString
                
                // Get rid of cell margins
                cell.layoutMargins = UIEdgeInsets.zero
                
                // Hide cell separator if user is invited, otherwise set separator inset to
                // align with right of profile image
                if isInvited {
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                } else {
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 0)
                }
        
                // Hide the repeat icon if the event is not recurring
                if event.recurrenceType == "NON" {
                    cell.repeatIcon.isHidden = true
                } else {
                    cell.repeatIcon.isHidden = false
                }
            }
            return cell
        }
        
        // If the user is invited, row 2 is the cell with the going/not going segmented control
        if indexPath.section == 0 && indexPath.row == 2 && isInvited {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventResponseCell", for: indexPath) as! EventResponseCell
            
            // Find out if the user is in the list of users who have accepted the invitation
            // and set  the segmentedControl appropriately
            if event.accepted?.contains(where: { acceptedUser in
                return acceptedUser.pk == userModelController?.user?.pk
            }) == true {
                cell.responseSegmentedControl.selectedSegmentIndex = 1
            } else {
                cell.responseSegmentedControl.selectedSegmentIndex = 0
            }
            cell.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 0)
            return cell
        }
        
        // Section 1, row 0 is for the event owner
        if (indexPath.section == 1 && indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventAttendeeCell", for: indexPath) as! EventAttendeeCell
            if let image = tribeModelController?.getProfileImageForTribePk(event.owner?.pk) {
                cell.profileImageView.image = image
            }
            cell.profileImageView.makeRounded()
            if let displayName = event.owner?.displayName {
                cell.displayNameLabel.text = displayName
            }
            cell.statusLabel.text = "Event owner"
            cell.statusLabel.textColor = UIColor(named: "THIcons")
            
            // Align separator with right of profile image
            cell.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 0)
            return cell
        } else {
            // Subsequent rows must be for members invited
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventAttendeeCell", for: indexPath) as! EventAttendeeCell
            if let tribeMember = event.to?[indexPath.row - 1] {
                
                // Find out if the user is attending
                var isGoing = false
                if let acceptedArray = event.accepted {
                    isGoing = acceptedArray.reduce(false) { acc, member in tribeMember.pk == member.pk || acc }
                }
                
                // Give them a colour profile image if they are attending, otherwise a B&W image,
                // and set statusLabel text appropriately
                if let image = tribeModelController?.getProfileImageForTribePk(tribeMember.pk) {
                    if isGoing {
                        cell.profileImageView.image = image
                        cell.statusLabel.text = "Going"
                        cell.statusLabel.textColor = UIColor(named: "THPositive")
                    } else {
                        let greyImage = image.greyImage
                        cell.profileImageView.image = greyImage
                        cell.statusLabel.text = "Not going"
                        cell.statusLabel.textColor = UIColor(named: "THGreyed")
                    }
                }
                cell.profileImageView.makeRounded()
                cell.profileImageView.contentMode = .scaleAspectFill
                
                // Align separator with right of profile image
                cell.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 0)
                
                if let displayName = tribeMember.displayName {
                    cell.displayNameLabel.text = displayName
                }
            }
            return cell
        }
    }
    
    // MARK: IBAction methods
    /// Handle's the user pressing the UISegmentedControl to indicate if they are attending/not attending
    @IBAction func responseValueChanged(_ sender: Any) {
        guard let eventPk = event?.id else { return }
        if let responseSegmentedControl = sender as? UISegmentedControl {
            
            // Find out if user selected to go or not go
            let isGoing = responseSegmentedControl.selectedSegmentIndex == 1
            
            // Try to register user's response with the API. Catch and display alerts for any errors
            Task.init {
                do {
                    try await eventsModelController?.didRespondToEventForPk(eventPk, isGoing: isGoing)
                    
                    // If the user is going to the event, append them to the accepted array for the event
                    // currently displayed in the tableView, otherwise remove them.
                    if isGoing {
                        if let userAsTribeMember = tribeModelController?.getTribeMemberForPk(userModelController?.user?.pk) {
                            event?.accepted?.append(userAsTribeMember)
                        }
                    } else {
                        if let accepted = event?.accepted {
                            for (index, tribeMember) in accepted.enumerated() {
                                if tribeMember.pk == userModelController?.user?.pk {
                                    event?.accepted?.remove(at: index)
                                }
                            }
                        }
                    }
                    
                    // Refresh the table view data
                    tableView.reloadData()
                } catch HTTPError.badRequest(let apiResponse) {
                    // If there's an error the event response was not registered by the API,
                    // so invert value of the selectedSegmentIndex so that the displayed going/not going value
                    // is in sync with the actual value
                    responseSegmentedControl.selectedSegmentIndex = responseSegmentedControl.selectedSegmentIndex ^ 1
                    self.dismiss(animated: true, completion: nil)
                    let errorMessage = apiResponse
                    let errorAlert = makeErrorAlert(title: "Error handling event response", message: "The server reported an error: \n\n\(errorMessage)")
                    self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
                } catch HTTPError.otherError(let statusCode) {
                    responseSegmentedControl.selectedSegmentIndex = responseSegmentedControl.selectedSegmentIndex ^ 1
                    self.dismiss(animated: true, completion: nil)
                    let errorAlert = makeErrorAlert(title: "Error handling event response", message: "Something went wrong handling your response. \n\nThe status code reported by the server was \(statusCode)")
                    self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
                } catch {
                    responseSegmentedControl.selectedSegmentIndex = responseSegmentedControl.selectedSegmentIndex ^ 1
                    self.dismiss(animated: true, completion: nil)
                    let errorAlert = makeErrorAlert(title: "Error handling event response", message: "Something went wrong handling your response. Please check you are online.")
                    self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
                }
                
                do {
                    // Tell the delegate there was a change to a calendar event. Events will be reloaded
                    // and the calendar view refreshed.
                    try await delegate?.calEventDetailsDidChange(shouldDismissSubview: false, event: nil)
                } catch {
                    print("Error reloading and refreshing events data in CalEventDetailsTableViewController: ", error)
                }
            }
        }
    }
    
    // MARK: tableView size methods
    // Resize the cell if the content is too big (e.g. a long event subject).
    // Approach to overriding this method to cause a specific cell to autoresize is from
    // https://www.hackingwithswift.com/example-code/uikit/how-to-make-uitableviewcells-auto-resize-to-their-content
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return UITableView.automaticDimension
        }
        else {
            return 68
        }
    }
    
    // Approach to overriding this method to cause a specific cell to autoresize is from
    // https://www.hackingwithswift.com/example-code/uikit/how-to-make-uitableviewcells-auto-resize-to-their-content
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableView.automaticDimension
        }
        else {
            return 68
        }
    }
    
    func eventDidChange() {
        Task.init {
            do {
                // Let the HomeViewController know that calendar event details changed so that
                // the user's edit is reflected in the UI
                try await delegate?.calEventDetailsDidChange(shouldDismissSubview: false, event: event)
            } catch {
                print("Error dealing with change to event in CalEventDetailsTableViewController")
            }
        }
        tableView.reloadData()
    }
}

// MARK: private extension
private extension CalEventDetailsTableViewController {
    func initialize() {
        tableView.estimatedRowHeight = 68
        
        // Remove cell separators
        tableView.separatorStyle = .singleLine
    }
}
