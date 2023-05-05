//
//  AccountViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 27/04/2023.
//

import UIKit

class AccountViewController: UIViewController, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    weak var userModelController: UserModelController?
    weak var tribeModelController: TribeModelController?
    var imagePickerController: UIImagePickerController?
    
    @IBOutlet weak var profileImageStackView: UIStackView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let accountTableViewController = self.children[0] as? AccountTableViewController {
            accountTableViewController.userModelController = self.userModelController
            accountTableViewController.tribeModelController = self.tribeModelController
        }
        
        self.imagePickerController = UIImagePickerController()
        self.imagePickerController!.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.profileImageView.image = self.userModelController?.user?.profileImage
        
        // Technique to use a round vertical UI stack view to create a round UIImage with edit button
        // is from https://stackoverflow.com/questions/58734620/add-a-button-on-top-of-imageview-similar-to-iphone-profile-setting-page
        self.profileImageStackView.clipsToBounds = true
        self.profileImageStackView.layer.cornerRadius = 40
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Get profile new profile image from image picker, and attempt to upload to the server.
        // If successful, set image of profileImageView and dismiss the image picker.
        if let newImage = info[.originalImage] as? UIImage {
            Task.init {
                do {
                    guard let pk = self.userModelController?.user?.pk else { return }
                    _ = try await self.userModelController?.doUpdateProfileImage(forPrimaryKey: pk, image: newImage)
                    self.profileImageView.image = newImage
                    self.dismiss(animated: true, completion: nil)
                } catch {
                    print("Error setting new profile image")
                }
            }
        }
    }
    
    @IBAction func didSelectImageEdit(_ sender: Any) {
        // User wants to edit profile image
        guard let imagePickerController = self.imagePickerController else {return}
        
        // Check if device has camera
        let canUseCamera = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        // If so create and present an action sheet to allow user to select camera or photo library,
        // and configue and present the image picker accordingly
        if canUseCamera {
            let imagePickerAlert = UIAlertController(title: nil, message: "Choose camera or photo library", preferredStyle: UIAlertController.Style.actionSheet)
            imagePickerController.sourceType = UIImagePickerController.SourceType.camera
            imagePickerAlert.addAction(UIAlertAction(title: "Camera", style: .default) {(result: UIAlertAction) -> Void in
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            })
            imagePickerAlert.addAction(UIAlertAction(title: "Photo library", style: .default) {(result: UIAlertAction) -> Void in
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            })
            imagePickerAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel) {(result: UIAlertAction) -> Void in return})
            self.present(imagePickerAlert, animated: true)
            
        // Otherwise, present image picker for photo library
        } else {
            imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
}
