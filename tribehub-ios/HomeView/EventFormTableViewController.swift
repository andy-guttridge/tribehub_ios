//
//  EventFormTableViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 26/05/2023.
//

import UIKit

class EventFormSubjectCell: UITableViewCell {
    @IBOutlet weak var subjectTextField: UITextField!
}

class EventFormDateTimeCell: UITableViewCell {
    
}

class EventFormDurationCell: UITableViewCell {
    
}

class EventFormCategoryCell: UITableViewCell {
    @IBOutlet weak var categoryPickerView: UIPickerView!
}

class EventFormRecurrenceCell: UITableViewCell {
    @IBOutlet weak var recurrencePickerView: UIPickerView!
}

class EventFormTribeMemberCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var tribeMemberNameLabel: UILabel!
}

class EventFormTableViewController: UITableViewController {
    
    
    var tribeModelController: TribeModelController?
    
    // Holds the event being edited if applicable
    var event: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Rows for section 0 are fixed, section 1 depends on the number of tribe members
        if section == 0 {
            return 5
        } else {
            return tribeModelController?.tribe?.tribeMembers.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 00 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectCell", for: indexPath)
            return cell
        }
        
        if indexPath.section == 00 && indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DateTimeCell", for: indexPath)
            return cell
        }
        
        if indexPath.section == 00 && indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DurationCell", for: indexPath)
            return cell
            
        }
        
        if indexPath.section == 00 && indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecurrenceCell", for: indexPath) as! EventFormRecurrenceCell
            cell.recurrencePickerView.delegate = self
            return cell
        }
        
        if indexPath.section == 00 && indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! EventFormCategoryCell
            cell.categoryPickerView.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TribeMemberCell", for: indexPath) as! EventFormTribeMemberCell
            if let avatarImage = tribeModelController?.tribe?.tribeMembers[indexPath.row].profileImage {
                cell.avatarImageView.image = avatarImage
                cell.avatarImageView.makeRounded()
            }
            if let displayName = tribeModelController?.tribe?.tribeMembers[indexPath.row].displayName {
                cell.tribeMemberNameLabel.text = displayName
            }
            // Align separator with right of profile images
            cell.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 0)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row > 1 {
            return 175
        }
        
        if indexPath.section == 1 {
            return 68
        } else {
            return 50
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .checkmark
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .none
            }
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

// MARK: Private extensions
extension EventFormTableViewController {
    func initialize() {
        // Customise navigation item title depending on whether an existing event
        // is being edited
        if let event = event {
            navigationItem.title = "Edit event"
            
            // Eventually we will need to populate the tableView with event details here
        } else {
            navigationItem.title = "Add event"
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Confirm", style: .done, target: self, action: #selector(confirmSubmit))
    }
    
    @objc func confirmSubmit() {
        print("Submit")
    }
}

// MARK: UIPickerViewDataSource extension
extension EventFormTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.superview?.superview is EventFormRecurrenceCell {
            return EventRecurrenceTypes.allCases.count
        }
        
        if pickerView.superview?.superview is EventFormCategoryCell {
            return EventCategories.allCases.count
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.superview?.superview is EventFormRecurrenceCell {
            return EventRecurrenceTypes.allCases[row].text
        }
        
        if pickerView.superview?.superview is EventFormCategoryCell {
            return EventCategories.allCases[row].text
        }
        
        return nil
    }
    
}
