//
//  EventFormTableViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 26/05/2023.
//

import UIKit

// MARK: Custom cell class definitions
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

// MARK: EventFormTableViewControllerDelegate protocol definition
protocol EventFormTableViewControllerDelegate {
    func calEventDetailsDidChange(shouldDismissSubview: Bool, event: Event?) async throws
}

// MARK: EventFormTableViewController class definition
class EventFormTableViewController: UITableViewController {
    
    var delegate: EventFormTableViewControllerDelegate?
    
    var userModelController: UserModelController?
    var tribeModelController: TribeModelController?
    var eventsModelController: EventsModelController?
    
    // Holds the event being edited if applicable
    var event: Event?
    
    // Enables the parent view controller to specify an initial date for
    // the startDatePicker
    var shouldStartEditingWithDate: Date?
    
    // Tribemembers currently selected in the tableView
    private var selectedTribeMemberPks: [Int?] = []
    
    // Properties to hold values of user input captured in tableViewCells
    private var subjectString: String?
    private var startDatePickerSelectedDate: Date?
    private var durationPickerSelectedDuration: TimeInterval?
    private var recurrencePickerSelectedRow: Int?
    private var categoryPickerSelectedRow: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectCell", for: indexPath) as! EventFormSubjectCell
            cell.subjectTextField.addTarget(self, action: #selector(subjectTextFieldDidChange), for: .editingChanged)
            
            // Set label text if user is editing existing event
            if let event = event {
                cell.subjectTextField.text = event.subject
            }
            return cell
        }
        
        // Section 0, row 1 is the cell with the event start date and time
        if indexPath.section == 00 && indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DateTimeCell", for: indexPath) as! EventFormDateTimeCell
            cell.startDatePicker.timeZone = TimeZone.gmt
            cell.startDatePicker.addTarget(self, action: #selector(startDatePickerDidChange), for: .valueChanged)
            
            // Set datePicker value if user is editing existing event, or with startEditingWithDate
            // if this was passed in, otherwise set the  corresponding property to the datePicker's starting value
            if let start = event?.start {
                cell.startDatePicker.date = start
            } else if let start = shouldStartEditingWithDate {
                cell.startDatePicker.date = start
                
                // Set to nil because we only want this value the first time the cell
                // is rendered
                shouldStartEditingWithDate = nil
            }  else {
                startDatePickerSelectedDate = cell.startDatePicker.date
            }
            return cell
        }
        
        // Section 0, row 2 is the cell with the event duration
        if indexPath.section == 00 && indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DurationCell", for: indexPath) as! EventFormDurationCell
            cell.durationDatePicker.addTarget(self, action: #selector(durationPickerDidChange), for: .valueChanged)
            
            // Set picker value if user is editing existing event, otherwise set the  corresponding
            // property to the picker's starting value
            if let duration = event?.duration {
                cell.durationDatePicker.countDownDuration = duration
            } else {
                durationPickerSelectedDuration = cell.durationDatePicker.countDownDuration
            }
            return cell
            
        }
        
        // Section 0, row 3 is the cell with the event recurrence type
        if indexPath.section == 00 && indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecurrenceCell", for: indexPath) as! EventFormRecurrenceCell
            cell.recurrencePickerView.delegate = self
            
            // Set picker value if user is editing existing event, otherwise set the  corresponding
            // property to the picker's starting value
            if let recurrenceType = event?.recurrenceType {
                let recurrenceTypeAsInt = EventRecurrenceTypes.allCases.firstIndex(of: EventRecurrenceTypes(rawValue: recurrenceType) ?? EventRecurrenceTypes.NON)
                cell.recurrencePickerView.selectRow(recurrenceTypeAsInt ??  0, inComponent: 0, animated: true)
                recurrencePickerSelectedRow = recurrenceTypeAsInt
            } else {
                recurrencePickerSelectedRow = cell.recurrencePickerView.selectedRow(inComponent: 0)
            }
            return cell
        }
        
        // Section 0, row 4 is the cell with the event category
        if indexPath.section == 00 && indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! EventFormCategoryCell
            cell.categoryPickerView.delegate = self
            
            // Set picker value if user is editing existing event, otherwise set the  corresponding
            // property to the picker's starting value
            if let categoryType = event?.category {
                let categoryTypeAsInt = EventCategories.allCases.firstIndex(of: EventCategories(rawValue: categoryType) ?? EventCategories.NON)
                cell.categoryPickerView.selectRow(categoryTypeAsInt ?? 0, inComponent: 0, animated: true)
                categoryPickerSelectedRow = categoryTypeAsInt
            } else {
                categoryPickerSelectedRow = cell.categoryPickerView.selectedRow(inComponent: 0)
            }
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
            
            // If user is editing an existing event, find out if this tribe member is invited to the event,
            // and give the cell selected status with a checkmark if so
            if let toArray = event?.to, let tribeMemberPk = tribeMembers?[indexPath.row].pk {
                let isInvited = toArray.reduce(false) { acc, tribeMember in tribeMemberPk == tribeMember.pk || acc }
                if isInvited {
                    cell.accessoryType = .checkmark
                    selectedTribeMemberPks.append(tribeMemberPk)
                }
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
                
                // Manually check if cell already has a checkmark, and if so deselect, remove the checkmark
                // and remove the tribeMember.pk from the selectedTribeMemberPks. We do this to prevent the user having
                // to tap the cell twice to deselect if an existing event is being edited and the tribeMember is already
                // invited. Might be a better way to deal with this?
                if cell.accessoryType == .checkmark {
                    tableView.deselectRow(at: indexPath, animated: false)
                    cell.accessoryType = .none
                    if let tribeMemberIndex = selectedTribeMemberPks.firstIndex(of: tribeMembers[indexPath.row].pk) {
                        selectedTribeMemberPks.remove(at: tribeMemberIndex)
                    }
                } else {
                    // Otherwise, it's a normal selection, so add the checkmark
                    // and add to selectedTribeMemberPks
                    cell.accessoryType = .checkmark
                    selectedTribeMemberPks.append(tribeMembers[indexPath.row].pk)
                }
                
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

// MARK: Private extension
extension EventFormTableViewController {
    func initialize() {
        // Customise navigation item title and set properties
        // depending on whether an existing event is being edited
        if let event = event {
            navigationItem.title = "Edit event"
            subjectString = event.subject
            startDatePickerSelectedDate = event.start
            durationPickerSelectedDuration = event.duration
        } else {
            navigationItem.title = "Add event"
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Confirm", style: .done, target: self, action: #selector(confirmSubmit))
        
    }
    
    /// Captures value of the subjectTextField when its value changes
    /// and sets the relevant property
    @objc func subjectTextFieldDidChange() {
        if let subjectCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? EventFormSubjectCell {
            subjectString = subjectCell.subjectTextField.text
        }
    }
    
    /// Captures values of startDatePicker when its value changes
    /// and sets the relevant property
    @objc func startDatePickerDidChange() {
        if let startDateCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? EventFormDateTimeCell {
            startDatePickerSelectedDate = startDateCell.startDatePicker.date
        }
    }
    
    @objc func durationPickerDidChange() {
        if let durationCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? EventFormDurationCell {
            durationPickerSelectedDuration = durationCell.durationDatePicker.countDownDuration
        }
    }
    
    /// Handles user confirming submission of a new event or of edits to an existing event
    @objc func confirmSubmit() {
        
        // Show alert if user has failed to enter a subject string before attempting to create an event
        if subjectString == nil {
            let errorAlert = makeErrorAlert(title: "No subject", message: "You cannot create a new event without entering a subject")
            self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
        }
        
        // Get data from properties
        guard let subjectText = subjectString,
              let startDate = startDatePickerSelectedDate,
              let duration = durationPickerSelectedDuration,
              let recurrenceSelectedRow = recurrencePickerSelectedRow,
              let categorySelectedRow = categoryPickerSelectedRow
        else { return }
        
        // Get correct enum values for picker values
        let recurrence = EventRecurrenceTypes.allCases[recurrenceSelectedRow]
        let category = EventCategories.allCases[categorySelectedRow]
        
        
        // Create array of invited tribe members for the newEvent we create below
        let toTribeMembers: [TribeMember]? = selectedTribeMemberPks.map() { pk in tribeModelController?.getTribeMemberForPk(pk) ?? TribeMember() }
        
        // Filter out any tribe members who aren't invited from the accepted array
        let accepted = event?.accepted?.filter() { tribeMember in event?.to?.contains
            { toMember in toMember.pk == tribeMember.pk} ?? false
        }
        
        if let event = event {
            
            // Create a new event instance with the changed details.
            // This is necessary as we need to pass it back to the delegate to make sure the new details
            // are reflected in the eventsDetailTableView.
            let newEvent = Event(
                id: event.id,
                owner: event.owner,
                to: toTribeMembers,
                start: startDate,
                durationString: intervalToHoursMinsSecondsStr(duration),
                recurrenceType: recurrence.rawValue,
                subject: subjectText,
                category: category.rawValue,
                accepted: accepted
            )
            
            Task.init {
                let spinnerView = addSpinnerViewTo(self)
                do {
                    if let eventId = event.id {
                        try await eventsModelController?.changeEvent(
                            eventPk: eventId,
                            toPk: selectedTribeMemberPks,
                            start: startDate,
                            duration: duration,
                            recurrenceType: recurrence,
                            subject: subjectText,
                            category: category)
                    }
                    removeSpinnerView(spinnerView)
                } catch HTTPError.badRequest(let apiResponse) {
                    removeSpinnerView(spinnerView)
                    self.dismiss(animated: true, completion: nil)
                    let errorMessage = apiResponse
                    let errorAlert = makeErrorAlert(title: "Error editing event", message: "The server reported an error: \n\n\(errorMessage)")
                    self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
                } catch HTTPError.otherError(let statusCode) {
                    removeSpinnerView(spinnerView)
                    self.dismiss(animated: true, completion: nil)
                    let errorAlert = makeErrorAlert(title: "Error editing event", message: "Something went wrong making the changes to your event. \n\nThe status code reported by the server was \(statusCode)")
                    self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
                } catch {
                    removeSpinnerView(spinnerView)
                    self.dismiss(animated: true, completion: nil)
                    let errorAlert = makeErrorAlert(title: "Error editing event", message: "Something went wrong making the changes to your event. Please check you are online.")
                    self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
                }
                
                do {
                    try await delegate?.calEventDetailsDidChange(shouldDismissSubview: true, event: newEvent)
                } catch {
                    print("EventFormTableViewController delegate threw an error fetching events and updating calendar")
                }
            }
        } else {
            // Ask eventsModelController to create a new event
    
            Task.init {
                let spinnerView = addSpinnerViewTo(self)
                do {
                    try await eventsModelController?.createEvent(
                        toPk: selectedTribeMemberPks,
                        start: startDate,
                        duration: duration,
                        recurrenceType: recurrence,
                        subject: subjectText,
                        category: category)
                    removeSpinnerView(spinnerView)
                } catch HTTPError.badRequest(let apiResponse) {
                    removeSpinnerView(spinnerView)
                    self.dismiss(animated: true, completion: nil)
                    let errorMessage = apiResponse
                    let errorAlert = makeErrorAlert(title: "Error adding event", message: "The server reported an error: \n\n\(errorMessage)")
                    self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
                } catch HTTPError.otherError(let statusCode) {
                    removeSpinnerView(spinnerView)
                    self.dismiss(animated: true, completion: nil)
                    let errorAlert = makeErrorAlert(title: "Error adding event", message: "Something went wrong adding your event. \n\nThe status code reported by the server was \(statusCode)")
                    self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
                } catch {
                    removeSpinnerView(spinnerView)
                    self.dismiss(animated: true, completion: nil)
                    let errorAlert = makeErrorAlert(title: "Error adding event", message: "Something went wrong adding your event. Please check you are online.")
                    self.view.window?.rootViewController?.present(errorAlert, animated: true) {return}
                }
                
                    do {
                        try await delegate?.calEventDetailsDidChange(shouldDismissSubview: true, event: nil)
                    } catch {
                        print("EventFormTableViewController delegate threw an error fetching events and updating calendar")
                    }
            }
        }
    }
}

// MARK: UIPickerViewDataSource extension
extension EventFormTableViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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
    
    /// Store the value of the recurrencePickerView or categoryPickerView when user selects a row
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.superview?.superview is EventFormRecurrenceCell {
            recurrencePickerSelectedRow = row
        }
        
        if pickerView.superview?.superview is EventFormCategoryCell {
            categoryPickerSelectedRow = row
        }
    }
    
}
