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
    
    
    @IBAction func didPressLogoutButton(_ sender: Any) {
        guard let userModelController = self.userModelController else {
            return
        }
        
        Task.init {
            do {
                let result = try await userModelController.doLogout()
                self.dismiss(animated: true)
            } catch {
                let alert = UIAlertController(title: "Logout Error", message:"There was an issue logging out.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: {alertAction in alert.dismiss(animated: true)}))
                self.present(alert, animated: true)
            }
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
