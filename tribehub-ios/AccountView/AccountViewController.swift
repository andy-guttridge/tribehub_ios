//
//  AccountViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 27/04/2023.
//

import UIKit

class AccountViewController: UIViewController {
    weak var userModelController: UserModelController?
    weak var tribeModelController: TribeModelController?

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var accountStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove manage tribe static table if user is not tribe admin
        if self.userModelController?.user?.isAdmin == false {
            accountStackView.arrangedSubviews.first?.removeFromSuperview()
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
