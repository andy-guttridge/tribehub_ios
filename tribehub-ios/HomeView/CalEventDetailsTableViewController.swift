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

class CalEventDetailsTableViewController: UITableViewController {
    var tribeModelController: TribeModelController?
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
        // #warning Incomplete implementation, return the number of rows
        return 2
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
        
        // Row 1 is start and end dates/times
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
                
                // Add the event owner's avatar to the cell
                if let eventOwnerImage = tribeModelController?.getProfileImageForTribePk(event.owner?.pk) {
                    addAvatarImageToContainerView(cell.avatarContainerView, withImage: eventOwnerImage)
                }
                
                // Iterate through the users invited to the event. If they've accepted the invitation,
                // add their standard avatar to the cell, if not then add a grey scale version
                for user in event.to ?? [] {
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
