//
//  AppDelegate.swift
//  Venues
//
//  Created by Harry Nguyen on 3/14/18.
//  Copyright © 2018 Harry Nguyen. All rights reserved.
//

import UIKit
import SwiftyJSON


let SocketURL = URL(string: "http://192.168.0.7")!
let ServerURL = URL(string: "http://192.168.0.7/graphql")!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window : UIWindow?

    
    var rootController : GenderOverviewController!
    
    var rootControllerSize : CGSize
    {
        get
        {
            var rootControllerSize = UIScreen.main.bounds.size
            //            rootControllerSize.width -= (self.window!.safeAreaInsets.left + self.window!.safeAreaInsets.right)
            //            rootControllerSize.height -= (self.window!.safeAreaInsets.top + self.window!.safeAreaInsets.bottom)
            
            if (rootControllerSize.height == UIScreen.main.bounds.size.height)
            {
                rootControllerSize.height -= UIApplication.shared.statusBarFrame.height
            }
            
            return rootControllerSize
        }
    }
    
    var rootControllerOrigin : CGPoint
    {
        get
        {
            var rootControllerOrigin = CGPoint.zero
            rootControllerOrigin.x = self.window!.safeAreaInsets.left
            rootControllerOrigin.y = self.window!.safeAreaInsets.top
            
            if (rootControllerOrigin.y == 0)
            {
                rootControllerOrigin.y = UIApplication.shared.statusBarFrame.height
            }
            
            return rootControllerOrigin
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool
    {
//        GMSServices.provideAPIKey("AIzaSyCoFhUubSNul0QLIf4pzexvtWbxuFx1bLI")
        
        self.rootController = GenderOverviewController()
        
        self.window!.rootViewController = self.rootController
        self.window!.backgroundColor = UIColor.white
        self.window!.makeKeyAndVisible()
        
        //        let appViewModel = ConsumerAppDetailViewModel(isNetworkEnabled: false)
        let rootViewModel = GenderOverviewViewModel()
        self.rootController.bind(viewModel: rootViewModel)
        self.rootController.render(size: self.rootControllerSize)
        self.rootController.view.frame.origin = self.rootControllerOrigin
        
        return true
    }
}

