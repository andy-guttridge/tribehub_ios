//
//  ViewController.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 24/03/2023.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Test logging in to the REST API and retrieving some data
        Task.init {
            do {
                await self.testApi()
            }
        }
    }
    
    func testApi() async {
        
        // Retrieve test login credentials from app bundle
        var credentials: NSDictionary?
        if let path = Bundle.main.path(forResource: "test_credentials", ofType: "plist") {
            credentials = NSDictionary(contentsOfFile: path)
        }
        
        // Create Alamofire session
        let session = Session.default
        
        // Create loginRequest onject for logging in and use the postData method to login with user credentials.
        // We get a LoginResponse object with the access token, refresh token and user profile
        let loginRequest = APIRequest(resource: UserResource(requestType: .login), session: session)
        do {
            if let response = try await loginRequest.postData(payload: credentials as? Dictionary<String, Any>) {
                print(response)
            }
        } catch {
            print(error)
        }
        
        // Create userProfileRequest object for retrieving the user profile and use to retrieve a profile
        let userProfileRequest = APIRequest(resource: UserResource(requestType: .profile), session: session)
        do {
            if let response = try await userProfileRequest.fetchData() {
                print(response)
            }
        } catch {
            print(error)
        }
        
        // Create tribeRequest object for retrieving user's tribe details and use to retrieve tribe members
        let tribeRequest = APIRequest(resource: TribeResource(), session: session)
        do {
            if let response = try await tribeRequest.fetchData() {
                print(response)
            }
        } catch {
            print(error)
        }
        
        // Create a logoutRequest object for logging out and use to logout. We get an empty LogInResponse object back.
        let logoutRequest = APIRequest(resource: UserResource(requestType: .logout), session: session)
        do {
            if let response = try await logoutRequest.postData(payload: nil) {
                print(response)
            }
        } catch {
            print(error)
        }
        
        
        // Log in to the API, retrieve user's tribe members and log out
        //        let baseUrl = "https://tribehub-drf.herokuapp.com"
        //        AF.request("\(baseUrl)/dj-rest-auth/login/", method: .post, parameters: credentials as! Parameters).responseJSON {response in
        //            debugPrint(response.value)
        //            AF.request("\(baseUrl)/tribe/").responseJSON {response in
        //                debugPrint(response.value)
        //                AF.request("\(baseUrl)/dj-rest-auth/logout/", method: .post).responseJSON {response in debugPrint(response)}
        //            }
        //        }
    }
}


