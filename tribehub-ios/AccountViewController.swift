//
//  AccountViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 21/04/2023.
//

import UIKit

class AccountViewController: UIViewController, UITableViewDataSource {
    
    weak var userModelController: UserModelController?
    weak var tribeModelController: TribeModelController?

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tribeTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.profileImageView.image = userModelController?.user?.profileImage
        self.profileImageView.makeRounded()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tribeModelController?.tribe?.tribeMembers.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tribeTableView.dequeueReusableCell(withIdentifier: "tribeMemberCell", for: indexPath)
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.image = self.tribeModelController?.tribe?.tribeMembers[indexPath.row].profileImage
        contentConfiguration.imageProperties.maximumSize = CGSize(width: 32, height: 32)
        contentConfiguration.text = self.tribeModelController?.tribe?.tribeMembers[indexPath.row].displayName
        cell.contentConfiguration = contentConfiguration
        return cell
    }

  
    @IBAction func didPressLogoutButton(_ sender: Any) {
        guard let userModelController = self.userModelController else {
                    return
                }
                
                Task.init {
                    do {
                        _ = try await userModelController.doLogout()
                        self.dismiss(animated: true)
                    } catch {
                        let alert = UIAlertController(title: "Logout Error", message:"There was an issue logging out.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: {alertAction in alert.dismiss(animated: true)}))
                        self.present(alert, animated: true)
                    }
                }
    }
}
