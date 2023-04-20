//
//  ViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 24/03/2023.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var password1TextField: UITextField!
    @IBOutlet weak var password2TextField: UITextField!
    
    var userModelController: UserModelController?
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mainAppViewController = segue.destination as? MainAppViewController {
            mainAppViewController.userModelController = self.userModelController
        }
    }
    
    @IBAction func didPressLoginButton(_ sender: Any) {
        
        guard let userModelController: UserModelController = self.userModelController else {
            return
        }
        
        var userDidEnterValidDetails = false
        let userName = self.userNameTextField.text
        let password1 = self.password1TextField.text
        let password2 = self.password2TextField.text
        
        // Check if text entered into all necessary fields, show alert if not
        if userName == "" || password1 == "" || password2 == "" {
            let alert = UIAlertController(title: "You must complete all fields", message:"You must enter a username and your password into both password fields. Please try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: {alertAction in alert.dismiss(animated: true)}))
            self.present(alert, animated: true) {
                userDidEnterValidDetails = false
            }
        } else if password1 != password2 {
            // Check if password fields match, show alert if not
            let alert = UIAlertController(title: "Incorrect Password", message:"The two passwords do not match. Please try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: {alertAction in alert.dismiss(animated: true)}))
            self.present(alert, animated: true) {
                userDidEnterValidDetails = false
            }
            
        } else {
            userDidEnterValidDetails = true
        }
        
        // Do login if login details correct
        if userDidEnterValidDetails {
            Task.init {
                do {
                    if let userName = userName, let password = password1 {
                        let user = try await userModelController.doLogin(userName: userName, passWord: password)
                        performSegue(withIdentifier: "loginSegue", sender: self)
                    }
                } catch {
                    print(error)
                    let alert = UIAlertController(title: "Login Error", message:"There was an error logging in. Please check your username and password, check you are online and try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: {alertAction in alert.dismiss(animated: true)}))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
