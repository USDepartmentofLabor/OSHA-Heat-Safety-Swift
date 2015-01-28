//
//  MoreInfoTableViewController.swift
//  Heat Tool
//
//  Created by Michael Pulsifer on 7/19/14.
//  Copyright (c) 2014 U.S. Department of Labor. All rights reserved.
//

import UIKit

class MoreInfoTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var moreInfoTableView: UITableView!
    
    var tableData: NSArray = ["Signs and Symptoms", "First Aid", "More Detail", "Contact OSHA", "About This App"]
    
    override func viewDidLoad() {
        
        NSLog("in fourth!")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: MoreInfoTableCell = MoreInfoTableCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "dolCell")
        
        var cellTitle = tableData[indexPath.row] as String
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        NSLog("%@", cellTitle)
        cell.textLabel?.text = tableData[indexPath.row] as? String
        
        switch cellTitle {
        case "Signs and Symptoms" :
            cell.imageView?.image = UIImage(named: "moreinfo_signs.png")
        case "First Aid":
            cell.imageView?.image = UIImage(named: "moreinfo_firstAid.png")
        case "More Detail":
            cell.imageView?.image = UIImage(named: "moreinfo_more.png")
        case "Contact OSHA":
            cell.imageView?.image = UIImage(named: "moreinfo_contact.png")
        case "About This App":
            cell.imageView?.image = UIImage(named: "moreinfo_about.png")
        default:
            println("default")
            
        }
        
        cell.imageView?.layer.masksToBounds = true;
        cell.imageView?.layer.cornerRadius = 5.0;
        
        return cell
    }
}
