//
//  ViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 24/03/2023.
//

import UIKit
import Alamofire

protocol LoginViewControllerDelegate {
    func dismissLoginModal()
}

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var password1TextField: UITextField!
    @IBOutlet weak var password2TextField: UITextField!
    
    weak var userModelController: UserModelController?
    weak var tribeModelController: TribeModelController?
    
    var delegate: LoginViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Clear input fields
        self.userNameTextField.text = ""
        self.password1TextField.text = ""
        self.password2TextField.text = ""
    }
    
    @IBAction func didPressLoginButton(_ sender: Any) {
        
        guard let userModelController: UserModelController = self.userModelController else {
            return
        }
        
        guard let tribeModelController: TribeModelController = self.tribeModelController else {
            return
        }
        
        var userDidEnterValidDetails = false
        let userName = self.userNameTextField.text
        let password1 = self.password1TextField.text
        let password2 = self.password2TextField.text
        
        // Check if text entered into all necessary fields, show alert if not
        if userName == "" || password1 == "" || password2 == "" {
            let errorAlert = makeErrorAlert(title: "You must complete all fields", message: "You must enter a username and your password into both password fields. Please try again.")
            self.present(errorAlert, animated: true) {
                userDidEnterValidDetails = false
            }
        } else if password1 != password2 {
            // Check if password fields match, show alert if not
            let errorAlert = makeErrorAlert(title: "Incorrect Password", message: "The two passwords do not match. Please try again.")
            self.present(errorAlert, animated: true) {
                userDidEnterValidDetails = false
            }
            
        } else {
            userDidEnterValidDetails = true
        }
        
        // Do login and fetch tribe data if login details correct
        if userDidEnterValidDetails {
            Task.init {
                if let userName = userName, let password = password1 {
                    do {
                        _ = try await userModelController.doLogin(userName: userName, passWord: password)
                        try await tribeModelController.getTribe()
                        self.delegate?.dismissLoginModal()
                    } catch {
                        print("Login error: ", error)
                        let errorAlert = makeErrorAlert(title: "Login Error", message: "There was an error logging in. Please check your username and password, check you are online and try again.")
                        self.present(errorAlert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
