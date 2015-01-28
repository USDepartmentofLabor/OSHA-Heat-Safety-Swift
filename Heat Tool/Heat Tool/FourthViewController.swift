//
//  FourthViewController.swift
//  Heat Tool
//
//  Created by Michael Pulsifer on 7/19/14.
//  Copyright (c) 2014 U.S. Department of Labor. All rights reserved.
//

import UIKit

class FourthViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var fourTableView: UITableView?
    
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
        let cell = tableView.dequeueReusableCellWithIdentifier("dolCell", forIndexPath: indexPath) as UITableViewCell
 
        var cellTitle = tableData[indexPath.row] as String
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        NSLog("%@", cellTitle)
        cell.textLabel!.text = tableData[indexPath.row] as? String
        
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
    
    // #pragma mark - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        NSLog("Dig deeper?")
        let thisCell:UITableViewCell = sender! as UITableViewCell
        let indexPath:NSIndexPath = self.fourTableView!.indexPathForCell(thisCell)!
        NSLog("%@", indexPath)
        let cellID = indexPath.item
        println(cellID)
        var viewContent = ""
        switch cellID {
        case 0:
            viewContent = "Signs and Symptoms"
        case 1:
            viewContent = "First Aid"
        case 2:
            viewContent = "More Detail"
        case 3:
            viewContent = "Contact OSHA"
        default:
            viewContent = "About This App"
        }
        
        if segue.identifier == "digDeeper" {
            (segue.destinationViewController as MoreInfoViewController).displayPage(viewContent)
        }
    }
}
