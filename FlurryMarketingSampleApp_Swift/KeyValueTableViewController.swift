//
//  KeyValueTableViewController.swift
//  FlurryMarketingSampleApp_Swift
//
//  Created by Yilun Xu on 9/27/18.
//  Copyright © 2018 com.flurry. All rights reserved.
//

import UIKit

class KeyValueTableViewController: UITableViewController {
    
    let appData = UserDefaults.standard.object(forKey: "data") as! Dictionary<String, String>
    var keys: [String]!
    var values: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keys = Array(appData.keys)
        values = Array(appData.values)
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
