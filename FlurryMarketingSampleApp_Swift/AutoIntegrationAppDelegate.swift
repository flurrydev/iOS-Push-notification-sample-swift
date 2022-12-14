//
//  AutoIntegrationAppDelegate.swift
//  FlurryMarketingSampleApp_Swift
//
//  Created by Yilun Xu on 10/2/18.
//  Copyright © 2018 com.flurry. All rights reserved.
//

import UIKit
// CoreLocation is not requried here.
import CoreLocation
import Flurry_iOS_SDK
import Flurry_Messaging

class AutoIntegratonAppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, FlurryMessagingDelegate {
    var window: UIWindow?
    let locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // ask for location permission from users if devs want to send notification based on location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            Flurry.trackPreciseLocation(true)
        }
    
        // set Auto Integration
        FlurryMessaging.setAutoIntegrationForMessaging()
        
        // get flurry infomation in the file "FlurryMarketingConfig.plist" and start flurry session
        if let path = Bundle.main.path(forResource: "FlurryMarketingConfig", ofType: "plist") {
            let info = NSDictionary(contentsOfFile: path)
            FlurryMessaging.set(delegate: self)
            let builder = FlurrySessionBuilder.init()
                .build(logLevel: .all)
                .build(appVersion: info?.object(forKey: "appVersion") as! String)
                .build(crashReportingEnabled: info?.object(forKey: "enableCrashReport") as! Bool)
            Flurry.startSession(apiKey: info?.object(forKey: "apiKey") as! String, sessionBuilder: builder)
        } else {
            print("please check your plist file")
        }
    
        return true

    }
    
    // MARK: - flurry messaging delegate methods
    
    // delegate method, invoked when a notification is received
    func didReceive(_ message: FlurryMessage) {
        print("didReceiveMessage = \(message.description)")
        // additional logic here
        
        /*
            Ex: Key value pair store.
            (FlurryMessage)message contians key-value pairs that set in the flurry portal when starting a compaign.
            You can get values by using message.appData["key name"].
            In this sample app,  all the key value information will be displayed in the KeyValueTableView.
         */
        
        let sharedPref = UserDefaults.standard
        sharedPref.set(message.appData, forKey: "data")
        sharedPref.synchronize()
    }
    
    // delegate method when a notification action is performed
    func didReceiveAction(withIdentifier identifier: String?, message: FlurryMessage) {
        print("didReceiveAction \(identifier ?? "no identifier"), Message = \(message.description)");
        // additional logic here
        
        // ex: key value pair store
        let sharedPref = UserDefaults.standard
        sharedPref.set(message.appData, forKey: "data")
        sharedPref.synchronize()
        
        // ex: deep links (open url)
        if let urlStr = message.appData!["deeplink"] {
            let appUrl = URL(string: urlStr as! String)
            UIApplication.shared.openURL(appUrl!)
            
        }
        
    }
    
    // MARK: - url scheme
    
    /*
        Optional method for deeplink usage, this method opens a resource specified by a URL (deeplink ex: flurry:// marketing/deeplink). It handles and manages the opening of registered urls and match those with specific destiniations within your app
     */
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == "flurry" && url.host == "marketing" && url.path == "/deeplink" {
            print("valid deeplink url")
            let rootViewController = self.window!.rootViewController as! UINavigationController
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let deeplinkVC = mainStoryboard.instantiateViewController(withIdentifier: "deeplink") as! DeeplinkViewController
            rootViewController.pushViewController(deeplinkVC, animated: true)
        }
        // add additional custom url scheme here to manage app deeplinking...
        return true
    }
    
    //MARK: -  location delegate
    // If users change location authorizaiont status, flurry will start/stop tracking users' location.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedAlways || status == CLAuthorizationStatus.authorizedWhenInUse {
            Flurry.trackPreciseLocation(true)
        } else {
            Flurry.trackPreciseLocation(false)
        }
    }
}
