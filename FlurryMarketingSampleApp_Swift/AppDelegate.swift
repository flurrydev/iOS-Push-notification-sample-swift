//
//  AppDelegate.swift
//  FlurryMarketingSampleApp_Swift
//
//  Created by Yilun Xu on 9/27/18.
//  Copyright © 2018 com.flurry. All rights reserved.
//

import UIKit
import Flurry_iOS_SDK
import Flurry_Messaging
// CoreLocation is not required here.
import CoreLocation

// @UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, FlurryMessagingDelegate, UNUserNotificationCenterDelegate, CLLocationManagerDelegate{
    
    var window: UIWindow?
    let locationManager = CLLocationManager()
    var flag: Bool!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // location service (optional), developers can send notifications to users based on location. If so, developers should ask for permission first.
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            Flurry.trackPreciseLocation(true)
        }
        // register remote notification for ios version >= 10 or < 10
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                // Enable or disable features based on authorization.
                if granted {
                    print("Notification enable successfully")
                } else {
                    print("push registration failed. ERROR: \(error?.localizedDescription ?? "error")")
                }
                
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        } else {
            // early iOS version support
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
            }
        }
 
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
            (FlurryMessage)message contians key-value pairs that set in the flurry portal when starting a compaign. You can get values by using message.appData["key name"].
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

    // MARK: - Notification Delegate methods

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // enable passing the device token to flurry
        FlurryMessaging.set(deviceToken: deviceToken)
    }

    private func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompleteionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if FlurryMessaging.isFlurryMsg(userInfo) {
            FlurryMessaging.receivedRemoteNotification(userInfo) {
                completionHandler(UIBackgroundFetchResult.newData)
            }
        }
    }

    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if FlurryMessaging.isFlurryMsg(response.notification.request.content.userInfo) {
            FlurryMessaging.receivedNotificationResponse(response) {
                completionHandler()
                // ... add your handling here, you can have your deeplink logic here
                
                /*
                    // ex: Get value for key "name" if there exists.
                    let userInfo = response.notification.request.content.userInfo
                    let appData = userInfo["appData"] as? NSDictionary
                    let name = appData!["name"] as? String
                    print(name ?? "no such key")
                 */
 
            }
        }
    }


    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // closure to implemnt what to do when notification arrives
        FlurryMessaging.presentNotification(notification, completionHandler: {
            completionHandler([.alert, .badge, .sound])
        })
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
