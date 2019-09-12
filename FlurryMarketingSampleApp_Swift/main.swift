//
//  main.swift
//  FlurryMarketingSampleApp_Swift
//
//  Created by Yilun Xu on 10/2/18.
//  Copyright © 2018 com.flurry. All rights reserved.
//

import UIKit

var delegateClass: AnyClass = AppDelegate.self

/// retrive the infomation in FlurryMarketingConfig.plist file to determine whether to use auto integration or not
if let path = Bundle.main.path(forResource: "FlurryMarketingConfig", ofType: "plist") {
    let data = NSDictionary(contentsOfFile: path)
    let isAuto = data?.object(forKey: "isAuto") as! Bool
    if isAuto {
        delegateClass = AutoIntegratonAppDelegate.self
    }
}
UIApplicationMain(
    CommandLine.argc,
    CommandLine.unsafeArgv,
    NSStringFromClass(UIApplication.self),
    NSStringFromClass(delegateClass)
)

