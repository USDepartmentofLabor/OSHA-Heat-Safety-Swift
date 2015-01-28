//
//  NowViewController.swift
//  Heat Tool
//
//  Created by Michael Pulsifer on 8/21/14.
//  Copyright (c) 2014 U.S. Department of Labor. All rights reserved.
//

import UIKit
import CoreLocation

class NowViewController: UIViewController, CLLocationManagerDelegate, WeatherProtocol {
    
    @IBOutlet var riskType: UILabel!
    @IBOutlet var perceivedTemperatureValue: UILabel!
    @IBOutlet var riskValue: UILabel!
    
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
            println("Emulator success!")
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
            println("Not an emulator")
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
/*            alert.addAction(UIAlertAction(title: "DC", style: .Default, handler: action in
                switch action.style{
                case .Default:
                    println("default")
                    break
                case .Cancel:
                    println("cancel")
                    break
                case .Destructive:
                    println("destructive")
                    break
                }
                }))
            
  */
            self.presentViewController(alert, animated: true, completion: nil)
            
            
        } else {
            self.riskValue.text = "Could not determine your location."
        }
    }
    
    func didCompleteForecast() {
        //NSLog("%d", self.newForecast.sevenDayForecast[0].maxHeatIndex)
        let maxHeatIndex = self.newForecast.sevenDayForecast[0].maxHeatIndex
        println("max heat index for today is \(self.newForecast.sevenDayForecast[0].maxHeatIndex)")
        var currentTemp = Int(self.newForecast.sevenDayForecast[0].temperature[0]["F"]!)
        println("current temperature is \(currentTemp)")
        let currentHeatIndex = Int(self.newForecast.sevenDayForecast[0].heatIndex[0]["F"]!)
        let currentWindChill = Int(self.newForecast.sevenDayForecast[0].windChill[0]["F"]!)
        println("current heat index is \(currentHeatIndex)")
        dispatch_async(dispatch_get_main_queue()) {
            switch currentTemp {
            case 80..<180:
                self.riskType.text = "Heat Index:"
                self.perceivedTemperatureValue.text = "\(currentHeatIndex)"
                switch currentHeatIndex {
                case 116..<180:
                    self.riskValue.text = "Extreme"
                case 104..<116:
                    self.riskValue.text = "high"
                case 91..<104:
                    self.riskValue.text = "moderate"
                default:
                    self.riskValue.text = "lower"
                }
            case -100..<50:
                self.riskType.text = "Wind Chill:"
                self.perceivedTemperatureValue.text = "\(currentWindChill)"
            default:
                self.riskType.text = "Temperature:"
                println(currentTemp)
                self.perceivedTemperatureValue.text = "\(currentTemp)"
            }
        }
        
    }

}


