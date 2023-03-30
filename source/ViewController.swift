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
        
        // Log in to the API, retrieve user's tribe members and log out
        let baseUrl = "https://tribehub-drf.herokuapp.com"
        AF.request("\(baseUrl)/dj-rest-auth/login/", method: .post, parameters: credentials as! Parameters).responseJSON {response in
            debugPrint(response.value)
            AF.request("\(baseUrl)/tribe/").responseJSON {response in
                debugPrint(response.value)
                AF.request("\(baseUrl)/dj-rest-auth/logout/", method: .post).responseJSON {response in debugPrint(response)}
            }
        }
    }
}


