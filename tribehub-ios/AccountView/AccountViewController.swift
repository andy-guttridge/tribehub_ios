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
        self.profileImageView.makeRounded()
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
