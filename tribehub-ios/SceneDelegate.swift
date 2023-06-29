//
//  SceneDelegate.swift
//  tribehub-ios
//
//  Created by Andy Guttridge on 24/03/2023.
//

import UIKit
import Alamofire

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var session: Session?
    var userModelController: UserModelController?
    var tribeModelController: TribeModelController?
    var eventsModelController: EventsModelController?
    var contactsModelController: ContactsModelController?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
     
        // Create RefreshRetrier, RequestAdapter and Interceptor.
        // Use these to create and configure an Alamofire session.
        let refreshRetrier = RefreshRequestRetrier()
        let refreshRequestAdapter = RefreshRequestAdapter()
        let interceptor = Interceptor(adapter: refreshRequestAdapter, retrier: refreshRetrier as RequestRetrier)
        let configuration = URLSessionConfiguration.af.default
        self.session = Session(configuration: configuration, interceptor: interceptor)
        
        // Create model controllers
        userModelController = tribehub_ios.UserModelController(withSession: self.session!)
        tribeModelController = tribehub_ios.TribeModelController(withSession: self.session!)
        eventsModelController = tribehub_ios.EventsModelController(withSession: self.session!)
        contactsModelController = tribehub_ios.ContactsModelController(withSession: self.session!)
    
        // userModelController needs a reference to tribeModelController, as it performs actions that can affect the tribe
        userModelController?.tribeModelController = self.tribeModelController
        
        // Pass model controllers to rootViewController
        if let tabBarViewController = self.window?.rootViewController as? TabBarViewController {
            tabBarViewController.userModelController = userModelController
            tabBarViewController.tribeModelController = tribeModelController
            tabBarViewController.eventsModelController = eventsModelController
            tabBarViewController.contactsModelController = contactsModelController
        } else {
            print("No tabBarViewController!")
        }
        
        // Set base font for app
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

