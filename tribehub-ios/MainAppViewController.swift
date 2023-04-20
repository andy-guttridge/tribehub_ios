//
//  ViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 20/04/2023.
//

import UIKit

class MainAppViewController: UIViewController {
    
    var userModelController: UserModelController?
    
    @IBOutlet weak var welcomeMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let displayName = self.userModelController?.user?.displayName {
            self.welcomeMessageLabel.text = "Logged in to TribeHub as \(displayName)!"
        }
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
