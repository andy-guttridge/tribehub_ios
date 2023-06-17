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
    @IBOutlet weak var passWordTextField: UITextField!
    
    weak var userModelController: UserModelController?
    weak var tribeModelController: TribeModelController?
    weak var eventsModelController: EventsModelController?
    
    var delegate: LoginViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Clear input fields
        self.userNameTextField.text = ""
        self.passWordTextField.text = ""
    }
    
    @IBAction func didPressLoginButton(_ sender: Any) {
        
        guard let userModelController: UserModelController = userModelController else {
            return
        }
        
        guard let tribeModelController: TribeModelController = tribeModelController else {
            return
        }
        
        guard let eventsModelController: EventsModelController = eventsModelController else {
            return
        }
        
        var userDidEnterValidDetails = false
        let userName = self.userNameTextField.text
        let password = self.passWordTextField.text
        
        // Check if text entered into all necessary fields, show alert if not
        if userName == "" || password == "" {
            let errorAlert = makeErrorAlert(title: "You must complete all fields", message: "You must enter a username and your password. Please try again.")
            self.present(errorAlert, animated: true) {
                userDidEnterValidDetails = false
            }
        } else {
            userDidEnterValidDetails = true
        }
        
        // Do login, then fetch tribe and events data if login details correct
        if userDidEnterValidDetails {
            Task.init {
                if let userName = userName, let password = password {
                    let spinnerView = addSpinnerViewTo(self)
                    do {
                        _ = try await userModelController.doLogin(userName: userName, passWord: password)
                        try await tribeModelController.getTribe()
                        removeSpinnerView(spinnerView)
                        self.delegate?.dismissLoginModal()
                    } catch {
                        removeSpinnerView(spinnerView)
                        print("Login error: ", error)
                        let errorAlert = makeErrorAlert(title: "Login Error", message: "There was an error logging in. Please check your username and password, check you are online and try again.")
                        self.present(errorAlert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
