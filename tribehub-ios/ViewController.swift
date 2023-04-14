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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Retrieve credentials
        if let path = Bundle.main.path(forResource: "test_credentials", ofType: "plist") {
            credentials = NSDictionary(contentsOfFile: path)
        }
        
        // Create RefreshRetrier, RequestAdapter and Interceptor.
        // Use these to create and configure an Alamofire session.
        let refreshRetrier = RefreshRequestRetrier()
        let refreshRequestAdapter = RefreshRequestAdapter()
        let interceptor = Interceptor(adapter: refreshRequestAdapter, retrier: refreshRetrier as RequestRetrier)
        let configuration = URLSessionConfiguration.af.default
        self.session = Session(configuration: configuration, interceptor: interceptor)
    }
        
    @IBAction func doLogin(_ sender: Any) {
        guard let session = self.session else {
            print("No Alamofire session in doLogin")
            return
        }
        
        // Create loginRequest object for logging in and use the postData method to login with user credentials.
        // We get an AuthResponse object with the access token, refresh token and user profile
        let loginRequest = APIRequest(resource: LoginResource(), session: session)
        Task.init {
            do {
                if let response = try await loginRequest.postData(payload: credentials as? Dictionary<String, Any>) {
                    print(response)

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
        
        Task.init {
            // Create tribeRequest object for retrieving user's tribe details and use to retrieve tribe members
            let tribeRequest = APIRequest(resource: TribeResource(), session: session)
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
        
        // Create a logoutRequest object for logging out and use to logout. We get an empty AuthResponse object back.
        let logoutRequest = APIRequest(resource: LogoutResource(), session: session)
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
