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
    @IBOutlet weak var startDatePicker: UIDatePicker!
}

class EventFormDurationCell: UITableViewCell {
    @IBOutlet weak var durationDatePicker: UIDatePicker!
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
    
    var userModelController: UserModelController?
    var tribeModelController: TribeModelController?
    var eventsModelController: EventsModelController?
    
    // Holds the event being edited if applicable
    var event: Event?
    
    // Tribemembers currently selected in the tableView
    private var selectedTribeMemberPks: [Int?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Rows for section 0 are fixed, section 1 depends on the number of tribe members minus the current user
        if section == 0 {
            return 5
        } else {
            return (tribeModelController?.tribe?.tribeMembers.count ?? 1) - 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Section 0, row 0 is the subject cell
        if indexPath.section == 00 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectCell", for: indexPath)
            return cell
        }
        
        // Section 0, row 1 is the cell with the event start date and time
        if indexPath.section == 00 && indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DateTimeCell", for: indexPath)
            return cell
        }
        
        // Section 0, row 2 is the cell with the event duration
        if indexPath.section == 00 && indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DurationCell", for: indexPath)
            return cell
            
        }
        
        // Section 0, row 3 is the cell with the event recurrence type
        if indexPath.section == 00 && indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecurrenceCell", for: indexPath) as! EventFormRecurrenceCell
            return cell
        }
        
        // Section 0, row 4 is the cell with the event category
        if indexPath.section == 00 && indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! EventFormCategoryCell
            return cell
        } else {
            
            // If it's not one of the above cells, it must be one of the tribe member cells
            let cell = tableView.dequeueReusableCell(withIdentifier: "TribeMemberCell", for: indexPath) as! EventFormTribeMemberCell
            
            // Filter out the current user from the tribeMembers so they can't invite themselves to the event
            let tribeMembers = tribeModelController?.tribe?.tribeMembers.filter() { member in member.pk != userModelController?.user?.pk}
            
            // Add avatar image to cell
            if let avatarImage = tribeMembers?[indexPath.row].profileImage {
                cell.avatarImageView.image = avatarImage
                cell.avatarImageView.makeRounded()
            }
            
            // Add display name to cell
            if let displayName = tribeMembers?[indexPath.row].displayName {
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
    
    /// Add checkmark to cell and add selected tribeMember.pk  to  selectedTribeMwemberPks if selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            // Filter out the current user from the tribeMembers so they can't invite themselves to the event
            let tribeMembers = tribeModelController?.tribe?.tribeMembers.filter() { member in member.pk != userModelController?.user?.pk}
            if let cell = tableView.cellForRow(at: indexPath), let tribeMembers = tribeMembers {
                cell.accessoryType = .checkmark
                selectedTribeMemberPks.append(tribeMembers[indexPath.row].pk)
            }
        }
    }
    
    /// Remove checkmark from cell and remove selected tribeMember.pk from selectedTribeMwemberPks if deselected
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            // Filter out the current user from the tribeMembers so they can't invite themselves to the event
            let tribeMembers = tribeModelController?.tribe?.tribeMembers.filter() { member in member.pk != userModelController?.user?.pk}
            if let cell = tableView.cellForRow(at: indexPath), let tribeMembers = tribeMembers, let tribeMemberIndex = selectedTribeMemberPks.firstIndex(of: tribeMembers[indexPath.row].pk) {
                cell.accessoryType = .none
                selectedTribeMemberPks.remove(at: tribeMemberIndex)
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
    
    /// Handles user confirming submission of a new event
    @objc func confirmSubmit() {
        
        // Get refs to UI elements we need to extract data from
        guard let subjectCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? EventFormSubjectCell,
              let startCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? EventFormDateTimeCell,
              let durationCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? EventFormDurationCell,
              let recurrenceCell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? EventFormRecurrenceCell,
              let categoryCell = tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? EventFormCategoryCell
        else { return }
        
        guard let subjectText = subjectCell.subjectTextField.text else { return }
        
        // Extract key event data from UI elements
        let start = startCell.startDatePicker.date
        let duration = durationCell.durationDatePicker.countDownDuration
        let recurrence = EventRecurrenceTypes.allCases[recurrenceCell.recurrencePickerView.selectedRow(inComponent: 0)]
        let category = EventCategories.allCases[categoryCell.categoryPickerView.selectedRow(inComponent: 0)]
        
        if let event = event {
            print("Handling changes to event: ", event)
        } else {
            // Ask eventsModelController to create a new event
            Task.init {
                do {
                   try await eventsModelController?.createEvent(
                        toPk: selectedTribeMemberPks,
                        start: start,
                        duration: duration,
                        recurrenceType: recurrence,
                        subject: subjectText,
                        category: category)
                } catch {
                    print(error)
                }
            }
        }
    }
}

// MARK: UIPickerViewDataSource extension
extension EventFormTableViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // If the pickerView is inside an EventFormRecurrence cell, it needs one less row than
        // there are recurrence types, as user should not be able to select a recurrence type of
        // 'Recurrence'
        if pickerView.superview?.superview is EventFormRecurrenceCell {
            return EventRecurrenceTypes.allCases.count - 1
        }
        if pickerView.superview?.superview is EventFormCategoryCell {
            return EventCategories.allCases.count
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        // Give the pickerView the recurrence type text or category text, depending on the
        // cell type
        if pickerView.superview?.superview is EventFormRecurrenceCell {
            return EventRecurrenceTypes.allCases[row].text
        }
        
        if pickerView.superview?.superview is EventFormCategoryCell {
            return EventCategories.allCases[row].text
        }
        
        return nil
    }
}
