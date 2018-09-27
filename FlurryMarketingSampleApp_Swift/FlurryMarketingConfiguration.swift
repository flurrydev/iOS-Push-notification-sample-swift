//
//  FlurryMarketingConfiguration.swift
//  FlurryMarketingSampleApp_Swift
//
//  Created by Yilun Xu on 9/27/18.
//  Copyright © 2018 com.flurry. All rights reserved.
//

import UIKit

class FlurryMarketingConfiguration: NSObject {
    var info: NSDictionary!
    static let sharedInstance = FlurryMarketingConfiguration()
    override private init () {
        let path = Bundle.main.path(forResource: "FlurryMarketingConfig", ofType: "plist")
        self.info = NSDictionary(contentsOfFile: path!)
    }
    
    func getApiKey() -> String {
        return info.object(forKey: "apiKey") as! String
    }
    
    func getSessionSeconds() -> Int {
        return info.object(forKey: "sessionSeconds") as! Int
    }
    
    func getCrashReport() -> Bool {
        return info.object(forKey: "enableCrashReport") as! Bool
    }
    
    func getAppVersion() -> String {
        return info.object(forKey: "appVersion") as! String
    }
}
