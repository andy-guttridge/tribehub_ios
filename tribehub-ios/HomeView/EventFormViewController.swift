//
//  EventFormViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 26/05/2023.
//

import UIKit

class EventFormViewController: UIViewController {
    
    // isEditingEvent tells us whether a new event is being created or an existing one edited
    var isEditingEvent: Bool = false
    var Event: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: private extension
private extension EventFormViewController {
    func initialize() {
        if isEditingEvent {
            navigationItem.title = "Edit event"
        } else {
            navigationItem.title = "Add event"
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Confirm", style: .done, target: self, action:#selector(confirmEvent))
    }
    
    @objc func confirmEvent() {
        print("Confirming event")
    }
}
