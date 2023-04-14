//
//  ViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 24/03/2023.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    var credentials: NSDictionary?
    var session: Session?
    var credential: DJAuthCredential?
    var authenticator: DJAuthAuthenticator?
    var interceptor: AuthenticationInterceptor<DJAuthAuthenticator>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Retrieve credentials
        if let path = Bundle.main.path(forResource: "test_credentials", ofType: "plist") {
            credentials = NSDictionary(contentsOfFile: path)
        }
        
        // Create Alamofire session
        self.session = Session.default
        self.authenticator = DJAuthAuthenticator()
    }
        
    @IBAction func doLogin(_ sender: Any) {
        guard let session = self.session else {
            print("No Alamofire session in doLogin")
            return
        }
        
        guard let authenticator = self.authenticator else {
            print("No Alamofire authenticator in doLogin")
            return
        }
        
        // Create loginRequest onject for logging in and use the postData method to login with user credentials.
        // We get a LoginResponse object with the access token, refresh token and user profile
        let loginRequest = APIRequest(resource: LoginResource(), session: session)
        Task.init {
            do {
                if let response = try await loginRequest.postData(payload: credentials as? Dictionary<String, Any>) {
                    print(response)
                    self.credential = response
                    self.interceptor = AuthenticationInterceptor(authenticator: authenticator, credential: response)
                }
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func fetchTribe(_ sender: Any) {
        guard let session = self.session else {
            print("No Alamofire session in fetchTribe")
            return
        }
        
        guard let interceptor = self.interceptor else {
            print("No Alamofire interceptor in doLogin")
            return
        }
        
        Task.init {
            // Create tribeRequest object for retrieving user's tribe details and use to retrieve tribe members
            let tribeRequest = APIRequest(resource: TribeResource(), session: session, interceptor: interceptor)
            do {
                if let response = try await tribeRequest.fetchData() {
                    print(response)
                }
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func doLogout(_ sender: Any) {
        guard let session = self.session else {
            print("No Alamofire session in doLogout")
            return
        }
        
        guard let interceptor = self.interceptor else {
            print("No Alamofire interceptor in doLogin")
            return
        }
        
        // Create a logoutRequest object for logging out and use to logout. We get an empty LogInResponse object back.
        let logoutRequest = APIRequest(resource: LogoutResource(), session: session, interceptor: interceptor)
        Task.init {
            do {
                if let response = try await logoutRequest.postData(payload: nil) {
                    print(response)
                }
            } catch {
                print(error)
            }
        }
    }
}
