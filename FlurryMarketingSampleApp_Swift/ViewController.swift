//
//  ViewController.swift
//  FlurryMarketingSampleApp_Swift
//
//  Created by Yilun Xu on 10/1/18.
//  Copyright © 2018 com.flurry. All rights reserved.
//

import UIKit
import AdSupport

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let str = identifierForAdvertising()
        print("this is the idfa \(str ?? "...")")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func identifierForAdvertising() -> String? {
        // Check whether advertising tracking is enabled
        guard ASIdentifierManager.shared().isAdvertisingTrackingEnabled else {
            return nil
        }
        
        // Get and return IDFA
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    
}
