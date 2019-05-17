//
//  KeyValueTableViewController.swift
//  FlurryMarketingSampleApp_Swift
//
//  Created by Yilun Xu on 10/1/18.
//  Copyright © 2018 com.flurry. All rights reserved.
//

import UIKit

class KeyValueTableViewController: UITableViewController {
    var keys: [String]!
    var values: [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Get all the key value pairs passing along with the notification.
        if UserDefaults.standard.object(forKey: "data") == nil {
            print("no key value pair")
        } else {
            let appData = UserDefaults.standard.object(forKey: "data") as! Dictionary<String, String>
            keys = Array(appData.keys)
            values = Array(appData.values)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = keys[indexPath.row]
        cell.detailTextLabel?.text = values[indexPath.row]
        return cell
    }


}
