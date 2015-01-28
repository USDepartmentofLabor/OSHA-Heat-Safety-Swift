//
//  DailyForecastCell.swift
//  Heat Tool
//
//  Created by Michael Pulsifer on 8/22/14.
//  Copyright (c) 2014 U.S. Department of Labor. All rights reserved.
//

import UIKit

class DailyForecastCell: UICollectionViewCell {
    
    @IBOutlet var highTemp: UILabel!
    @IBOutlet var dayOfWeek: UILabel!
    @IBOutlet var lowChill: UILabel!

    required init(coder aDecoder: (NSCoder!))
    {
        super.init(coder: aDecoder)
        // Your intializations
    }
 
}