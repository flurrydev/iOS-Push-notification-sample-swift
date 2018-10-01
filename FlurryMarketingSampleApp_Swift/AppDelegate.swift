//
//  AppDelegate.swift
//  FlurryMarketingSampleApp_Swift
//
//  Created by Yilun Xu on 9/27/18.
//  Copyright © 2018 com.flurry. All rights reserved.
//

import UIKit
import Flurry_iOS_SDK
import CoreLocation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, FlurryMessagingDelegate, UNUserNotificationCenterDelegate, CLLocationManagerDelegate{
    
    var window: UIWindow?
    let locationManager = CLLocationManager()
    var flag: Bool!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        flag = false
        
        // location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            Flurry.trackPreciseLocation(true)
        }
        if flag {
            // AUTO USE
            FlurryMessaging.setAutoIntegrationForMessaging()
        } else {
            // MANUAL USE
            // register
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
                    application.registerForRemoteNotifications()
                    
                }
            } else {
                // early version support
                UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
 
        // start flurry session
        if let path = Bundle.main.path(forResource: "FlurryMarketingConfig", ofType: "plist") {
            let info = NSDictionary(contentsOfFile: path)
            FlurryMessaging.setMessagingDelegate(self)
            let builder = FlurrySessionBuilder.init()
                .withLogLevel(FlurryLogLevelAll)
                .withAppVersion(info?.object(forKey: "appVersion") as! String)
                .withCrashReporting(info?.object(forKey: "enableCrashReport") as! Bool)
                .withSessionContinueSeconds(info?.object(forKey: "sessionSeconds") as! Int)
                .withIncludeBackgroundSessions(inMetrics: true)
            Flurry.startSession(info?.object(forKey: "apiKey") as! String, with: builder)
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
        
        // ex: key value pair store
        print("here")
        message.appData?.forEach { print("\($0): \($1)") }
        print("there")
        let sharedPref = UserDefaults.standard
        sharedPref.set(message.appData, forKey: "data")
        sharedPref.synchronize()
    }
    
    // delegate method when a notification action is performed
    func didReceiveAction(withIdentifier identifier: String?, message: FlurryMessage) {
        print("didReceiveAction \(identifier ?? "no identifier"), Message = \(message.description)");
        // additional logic here
        
        // ex: key value pair store
        message.appData?.forEach { print("\($0): \($1)") }
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
    
    // url scheme
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print("url is : \(url.absoluteString)")
        print("url host is : \(url.host ?? "default host")")
        print("url path is : \(url.path)")
        print("url schme is : \(url.scheme ?? "default schme")")
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
    

    // MARK: - manual integration delegate method

    // set device token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let   tokenString = deviceToken.reduce("", {$0 + String(format: "%02X",    $1)})
        // kDeviceToken=tokenString
        print("deviceToken: \(tokenString)")
    }

    // notification received & clicked (ios 7+)
    private func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompleteionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("log notification ios 7")
        if FlurryMessaging.isFlurryMsg(userInfo) {
            FlurryMessaging.receivedRemoteNotification(userInfo) {
                completionHandler(UIBackgroundFetchResult.newData)
            }
        }
    }

    // notification received response (ios 10)
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if FlurryMessaging.isFlurryMsg(response.notification.request.content.userInfo) {
            print("log response ios 10")
            FlurryMessaging.receivedNotificationResponse(response) {
                completionHandler()
            }
        }
    }

    // notification received in foreground (ios 10)
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // foregroud display
        print("foreground")
        FlurryMessaging.present(notification) {
            completionHandler([.alert, .badge, .sound])
        }
    }
    
    //MARK: -  location delegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedAlways || status == CLAuthorizationStatus.authorizedWhenInUse {
            Flurry.trackPreciseLocation(true)
        } else {
            Flurry.trackPreciseLocation(false)
        }
    }
    
    // MARK: - default
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}
