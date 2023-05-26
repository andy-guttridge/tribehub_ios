//
//  CalEventDetailsTableViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 19/05/2023.
//

import UIKit

class EventTitleCell: UITableViewCell {
    @IBOutlet weak var titleCategoryImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
}

class EventDateCell: UITableViewCell {
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var avatarContainerView: UIView!
}

class EventResponseCell: UITableViewCell {
    @IBOutlet weak var responseSegmentedControl: UISegmentedControl!
}

class ToTagsCell: UITableViewCell {
    @IBOutlet weak var toTagsContainerView: UIView!
}

protocol CalEventDetailsTableViewControllerDelegate {
    func calEventDetailsDidChange() async throws
}

class CalEventDetailsTableViewController: UITableViewController {
    weak var userModelController: UserModelController?
    weak var tribeModelController: TribeModelController?
    weak var eventsModelController: EventsModelController?
    
    var delegate: CalEventDetailsTableViewControllerDelegate?
    
    var event: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // If user has been invited to event, we need an extra row to show the 'not going/going' segmented control
        if let toUsers = event?.to {
            if toUsers.contains(where: { user in
                return userModelController?.user?.pk == user.pk
            }) {
                return 4
            }
        }
        return 3
    }
    
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
                    try await delegate?.calEventDetailsDidChange()
                    
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
                } catch {
                    print("Error reloading and refreshing events data in CalEventDetailsTableViewController: ", error)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let event = event else { return tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)}
        
        // Row 0 is category icon and subject
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventTitleCell", for: indexPath) as! EventTitleCell
            if let category = event.category {
                cell.titleCategoryImage.image = EventCategories(rawValue: category)?.image.withRenderingMode(.alwaysTemplate)
                cell.titleCategoryImage.tintColor = .systemIndigo
            }
            cell.titleLabel.text = event.subject
            
            // Approach to using numberOfLines and sizeToFit to cause the cell to size itself to fit its content is from
            // https://stackoverflow.com/questions/5430890/uilabel-auto-resize-on-basis-of-text-to-be-shown
            cell.titleLabel.numberOfLines = 0
            cell.titleLabel.sizeToFit()
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        }
        
        // Row 1 is profile avatars, and start and end dates/times
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventDateCell", for: indexPath) as! EventDateCell
            if let startDate = event.start, let duration = event.duration {
                
                // Use date formatter to extract time and date strings from event start and end date.
                // We have to calculate the end date from the start date and duration
                let dateFormatter = DateFormatter()
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
                cell.separatorInset = UIEdgeInsets.zero
                cell.layoutMargins = UIEdgeInsets.zero
                
                // Remove any avatars already in the cell
                for view in cell.avatarContainerView.subviews {
                    view.removeFromSuperview()
                }
                
                // Add the event owner's avatar to the cell
                if let eventOwnerImage = tribeModelController?.getProfileImageForTribePk(event.owner?.pk) {
                    addAvatarImageToContainerView(cell.avatarContainerView, withImage: eventOwnerImage)
                }
                
                // Iterate through the users invited to the event. If they've accepted the invitation,
                // add their standard avatar to the cell, if not then add a grey scale version. Exit the loop
                // early if there are more than 4 users invited.
                if let toArray = event.to {
                    for (index, user) in toArray.enumerated() {
                        if index > 3 { break }
                        if let eventInvitedImage = tribeModelController?.getProfileImageForTribePk(user.pk) {
                            if event.accepted?.contains(where: { acceptedUser in
                                return acceptedUser.pk == user.pk
                            }) == true {
                                addAvatarImageToContainerView(cell.avatarContainerView, withImage: eventInvitedImage)
                            } else {
                                let greyEventInvitedImage = eventInvitedImage.greyImage
                                addAvatarImageToContainerView(cell.avatarContainerView, withImage: greyEventInvitedImage)
                            }
                        }
                    }
                    
                    // If more than 4 users are invited, create an avatar image with a '+n' string to
                    // show how many additional users are invited that can't fit onto the cell
                    if toArray.count > 4 {
                        let tribeExcess = toArray.count - 4
                        let textImage = imageFromString("+\(String(tribeExcess))", width: 500, height: 500)!
                        addAvatarImageToContainerView(cell.avatarContainerView, withImage: textImage)
                    }
                }
            }
            return cell
        }
        
        // Row 2 is the cell with the to tags
        if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ToTagsCell", for: indexPath) as! ToTagsCell
        
            let tagHeight:CGFloat = 24
            let tagPadding: CGFloat = 3
            let tagSpacingX: CGFloat = 3
            let tagSpacingY: CGFloat = 3
        
            var intrinsicHeight: CGFloat = 0
        
            while cell.toTagsContainerView.subviews.count > event.to?.count ?? 0 {
                cell.toTagsContainerView.subviews[0].removeFromSuperview()
            }
        
            while cell.toTagsContainerView.subviews.count < event.to?.count ?? 0 {
                let newLabel = UILabel()
        
                newLabel.textAlignment = .center
                newLabel.backgroundColor = .systemIndigo
                newLabel.layer.masksToBounds = true
                newLabel.layer.cornerRadius = 8
                newLabel.layer.borderColor = UIColor.systemPink.cgColor
                newLabel.layer.borderWidth = 1
                newLabel.textColor = .white
        
                cell.toTagsContainerView.addSubview(newLabel)
                for (tribeMember, v) in zip(event.to ?? [], cell.toTagsContainerView.subviews) {
                    guard let label = v as? UILabel else {
                        fatalError("non-UILabel subview found!")
                    }
                    label.text = tribeMember.displayName
                    label.frame.size.width = label.intrinsicContentSize.width + tagPadding
                    label.frame.size.height = tagHeight
                }
        
                var currentOriginX: CGFloat = 0
                var currentOriginY: CGFloat = 0
        
                // for each label in the array
                cell.toTagsContainerView.subviews.forEach { v in
        
                    guard let label = v as? UILabel else {
                        fatalError("non-UILabel subview found!")
                    }
        
                    // if current X + label width will be greater than container view width
                    //  "move to next row"
                    if currentOriginX + label.frame.width > cell.toTagsContainerView.bounds.width {
                        currentOriginX = 0
                        currentOriginY += tagHeight + tagSpacingY
                    }
        
                    // set the btn frame origin
                    label.frame.origin.x = currentOriginX
                    label.frame.origin.y = currentOriginY
        
                    // increment current X by btn width + spacing
                    currentOriginX += label.frame.width + tagSpacingX
        
                }
            }
            return cell
        }
        
        // Row 3 is the cell with the going/not going segmented control
        if indexPath.row == 3 {
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
            return cell
        }
        
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            return cell
        }
    }
    
    // Resize the cell if the content is too big (e.g. a long event subject).
    // Approach to overriding this method to cause a specific cell to autoresize is from
    // https://www.hackingwithswift.com/example-code/uikit/how-to-make-uitableviewcells-auto-resize-to-their-content
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

private extension CalEventDetailsTableViewController {
    func initialize() {
        tableView.estimatedRowHeight = 68
        
        // Make cell separators invisible
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    /// Adds a UIImage for the specified image to the cell's avatarContainerView
    func addAvatarImageToContainerView(_ containerView: UIView?, withImage image: UIImage) {
        guard let containerView = containerView else { return }
        
        // Find out how many avatars are already displayed and make sure the new avatar
        // has the highest z-position
        let numberOfAvatars = containerView.subviews.count
        let newZPosition = (containerView.subviews.last?.layer.zPosition ?? 0) + 1
        
        // Create and configure new UIImageView
        let newAvatarImageView = UIImageView()
        newAvatarImageView.frame.size = CGSize(width: 50, height: 50)
        newAvatarImageView.makeRounded()
        newAvatarImageView.image = image
        newAvatarImageView.translatesAutoresizingMaskIntoConstraints = false
        newAvatarImageView.contentMode = .scaleAspectFill
        newAvatarImageView.layer.zPosition = newZPosition
        containerView.addSubview(newAvatarImageView)
        
        // Add layout constraints with the x position based on the number of existing avatars,
        // to make sure they overlap and are equally spaced
        NSLayoutConstraint.activate([
            newAvatarImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: CGFloat(18 * numberOfAvatars + 3)),
            newAvatarImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 3),
            newAvatarImageView.heightAnchor.constraint(equalToConstant: 50),
            newAvatarImageView.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
}
