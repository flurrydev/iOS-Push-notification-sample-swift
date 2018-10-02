//
//  main.swift
//  FlurryMarketingSampleApp_Swift
//
//  Created by Yilun Xu on 10/2/18.
//  Copyright © 2018 com.flurry. All rights reserved.
//

import UIKit

UIApplicationMain(
    CommandLine.argc,
    UnsafeMutableRawPointer(CommandLine.unsafeArgv)
        .bindMemory(
            to: UnsafeMutablePointer<Int8>.self,
            capacity: Int(CommandLine.argc)
    ),
    NSStringFromClass(UIApplication.self),
    NSStringFromClass(AppDelegate.self)
)

