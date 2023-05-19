//
//  CalEventDetailsViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 19/05/2023.
//

import UIKit

class CalEventDetailsViewController: UIViewController {
    
    var event: Event?

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the event to the child tableViewController
        if let calEventTableViewController = segue.destination as? CalEventDetailsTableViewController {
            calEventTableViewController.event = event
        }
    }
}

private extension CalEventDetailsViewController {
    func initialize() {
        self.title = "Event details"
    }
}
