//
//  SecondViewController.swift
//  Heat Tool
//
//  Created by Michael Pulsifer on 7/19/14.
//  Copyright (c) 2014 U.S. Department of Labor. All rights reserved.
//

import UIKit
import CoreLocation

class SecondViewController: UICollectionViewController, UICollectionViewDataSource, UICollectionViewDelegate, CLLocationManagerDelegate, WeatherProtocol {
    
    
    
    // location
    var locationManager:CLLocationManager!
    var curLat = 42.46 as Double
    var curLon = -71.25
    let newForecast = Weather(lat: "42.46",long: "-71.25")

    required init(coder aDecoder: (NSCoder!))
    {
        super.init(coder: aDecoder)
        // Your intializations
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        newForecast.delegate = self
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        if UIDevice.currentDevice().model == "iPhone Simulator" {
            println("Emulator!")
            var alert = UIAlertController(title: "Emulator", message: "Choose a location you would like to test against.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "DC", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
                self.newForecast.latitude = "38.8951"
                self.newForecast.longitude = "-77.0367"
                self.newForecast.refreshWeatherData()
                
            }))
            alert.addAction(UIAlertAction(title: "Barrow", style: UIAlertActionStyle.Cancel, handler: {(alert :UIAlertAction!) in
                self.newForecast.latitude = "71.2956"
                self.newForecast.longitude = "-156.7664"
                self.newForecast.refreshWeatherData()
                
            }))
            alert.addAction(UIAlertAction(title: "San Juan", style: UIAlertActionStyle.Destructive, handler: {(alert :UIAlertAction!) in
                self.newForecast.latitude = "18.45"
                self.newForecast.longitude = "-66.0667"
                self.newForecast.refreshWeatherData()
                
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            println("Not in emulator")
        }
        
        self.locationManager.stopUpdatingLocation()
        self.curLat = newLocation.coordinate.latitude
        self.curLon = newLocation.coordinate.longitude
        
        self.newForecast.latitude = "\(self.curLat)"
        self.newForecast.longitude = "\(self.curLon)"
        println("Latitude: \(newLocation.coordinate.latitude)")
        // get data
        self.newForecast.refreshWeatherData()
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        //fail gracefully
        // set default location because the location could not be determined
        if UIDevice.currentDevice().model == "iPhone Simulator" {
            println("Emulator!")
            
            // Let's choose a location!
            var alert = UIAlertController(title: "Emulator", message: "Choose a location you would like to test against.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "DC", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
                self.newForecast.latitude = "38.8951"
                self.newForecast.longitude = "-77.0367"
                self.newForecast.refreshWeatherData()
                
            }))
            alert.addAction(UIAlertAction(title: "Barrow", style: UIAlertActionStyle.Cancel, handler: {(alert :UIAlertAction!) in
                self.newForecast.latitude = "71.2956"
                self.newForecast.longitude = "-156.7664"
                self.newForecast.refreshWeatherData()
                
            }))
            alert.addAction(UIAlertAction(title: "San Juan", style: UIAlertActionStyle.Destructive, handler: {(alert :UIAlertAction!) in
                self.newForecast.latitude = "18.45"
                self.newForecast.longitude = "-66.0667"
                self.newForecast.refreshWeatherData()
                
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            
            
        } else {
            //self.riskValue.text = "Could not determine your location."
            println("Could not determine location")
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        println("Daily forecast count = \(newForecast.sevenDayForecast.count)")
        return newForecast.sevenDayForecast.count
    }

   /* override func collectionView(collectionView: UICollectionView!, didDeselectItemAtIndexPath indexPath: NSIndexPath!) {
        code
    }
    */
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // stuff
        var cell: DailyForecastCell! = collectionView.dequeueReusableCellWithReuseIdentifier("dailyForecast", forIndexPath: indexPath) as DailyForecastCell
        
        //let tempTemp =  Int(self.newForecast.sevenDayForecast[indexPath.row].temperature[2]["F"]!)
        let tempTemp =  (Int(self.newForecast.sevenDayForecast[indexPath.row].maxHeatIndex) >= 80 ? Int(self.newForecast.sevenDayForecast[indexPath.row].maxHeatIndex) : 0)
        let tempChill = (Int(self.newForecast.sevenDayForecast[indexPath.row].minWindChillF) < 50 ? Int(self.newForecast.sevenDayForecast[indexPath.row].minWindChillF) : 100)
        //let temDay = self.newForecast.sevenDayForecast[indexPath.row].forecastTime[0] as NSDate
        var dateFmt = NSDateFormatter()
        dateFmt.dateFormat = "EEEE"
       // let tempDay = dateFmt.stringFromDate(self.newForecast.sevenDayForecast[indexPath.row].forecastTime[0])
        
        dispatch_async(dispatch_get_main_queue()) {

            cell.highTemp.text = (tempTemp == 0 ? "-" : "\(tempTemp)")
            cell.lowChill.text = (tempChill == 100 ? "-" : "\(tempChill)")
            cell.dayOfWeek.text = "\(dateFmt.stringFromDate(self.newForecast.sevenDayForecast[indexPath.row].forecastTime[0]))"
        println(tempTemp)
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // put segue code here
    }
    
    func didCompleteForecast() {
        //stuff
        println("got the data back")
        dispatch_async(dispatch_get_main_queue()) {
        self.collectionView!.reloadData()
        }
    }
}

