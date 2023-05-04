//
//  AccountViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 27/04/2023.
//

import UIKit

class AccountViewController: UIViewController, UITableViewDelegate {
    weak var userModelController: UserModelController?
    weak var tribeModelController: TribeModelController?

    @IBOutlet weak var profileImageStackView: UIStackView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let accountTableViewController = self.children[0] as? AccountTableViewController {
            accountTableViewController.userModelController = self.userModelController
            accountTableViewController.tribeModelController = self.tribeModelController
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.profileImageView.image = self.userModelController?.user?.profileImage
        
        // Technique to use a round vertical UI stack view to create a round UIImage with edit button
        // is from https://stackoverflow.com/questions/58734620/add-a-button-on-top-of-imageview-similar-to-iphone-profile-setting-page
        self.profileImageStackView.clipsToBounds = true
        self.profileImageStackView.layer.cornerRadius = 40
        // self.profileImageView.makeRounded()
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
