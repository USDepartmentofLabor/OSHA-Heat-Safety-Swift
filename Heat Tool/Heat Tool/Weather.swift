//
//  Weather.swift
//
//  Created by Michael Pulsifer (U.S. Department of Labor) on 6/25/14.
//  Public Domain Software
//

import Foundation

protocol WeatherProtocol {
    func didCompleteForecast()
}

class Weather : GovDataRequestProtocol {
    
    var delegate: WeatherProtocol? = nil

    var latitude = ""
    var longitude = ""
    var feelsLike = PerceivedTemperature()
    var conversion = Conversions()

    // dailyForecast contains the weather data from NOAA, segregated by day
    struct dailyForecast {
        var forecastTime = [NSDate]()
        // dewPoint is an array of dictionaries (F, C)
        var dewPoint = [[String:Int]]()
        // heatIndex is an array of dictionaries (F, C)
        var heatIndex = [[String:Int]]()
        // windSpeed is an array of dictionaries (MPH, KPH)
        var windSpeed=[[String:Int]]()
        var cloudAmount = [Int]()
        var probabilityOfPrecipitation = [Int]()
        var humidity = [Int]()
        var windDirection = [Int]()
        // temperature is an array of dictionaries (F, C)
        var temperature = [[String:Int]]()
        var windGust = [[String:Int]]()
        var windChill = [[String:Int]]()
        var windChillGust = [[String:Int]]()
        //var quantitativePrecipitation = [[String:Double]]()
        // weather conditions is an array of dictionaries.  First is the additive and the second is the condition.
        var weatherConditions = [[String:String]]()
        var maxHeatIndex = 79
        var minWindChillF = 50
        var minWindChillC = 10
        
    }
    
    var tempDict = Dictionary<String,String>()
    var tempArray = [String]()
    
    // Array of daily forecasts
    var sevenDayForecast = [dailyForecast]()
    

    
    
    // NOAA API setup
    var apiMethod = "MapClick.php"
    var arguments = Dictionary<String,String>()
        
    var forecastRequest: GovDataRequest = GovDataRequest(APIKey: "", APIHost: "http://forecast.weather.gov", APIURL: "")
    
    
    init(lat:String,long:String) {
        self.latitude = lat
        self.longitude = long
        self.arguments["lat"] = self.latitude
        self.arguments["lon"] = self.longitude
        self.arguments["FcstType"] = "digitalDWML"
        forecastRequest.responseFormat = "XML"
        forecastRequest.delegate = self
        
    }
    
    func refreshWeatherData () {
        arguments["lat"] = self.latitude
        arguments["lon"] = self.longitude
        forecastRequest.callAPIMethod(method: apiMethod, arguments: arguments)
    }
    
    func parseNOAADateTime(noaaDate: String) -> NSDate {
        /*
            This function takes the dateTime format provided by NOAA and returns a usable NSDate value
            This should be replaced with something much more efficient, should there be a better way
        */
        
//        let format="yyyy-MM-dd HH:mm"
        let format="yyyy-MM-dd HH:mm"
        
        //Sample dateTime format from NOAA:  2014-07-24T05:00:00-08:00
        func timeZoneAdjust (year: Int, month: Int, day: Int, hour: Int, hourModifier: Int, timeOperator:NSString) -> (newYear:Int, newMonth:Int, newDay:Int, newHour:Int){
            /*
                This function evalutates the timezone offest provided by NOAA and makes the appropriate adjustment.
            
                This approach is a bit of a hack, but seemingly necessary because NSTimeZone's timezone by seconds from GMT ignores daylight savings time.
            */

            let tempHour = hour
            
            let monthDays = [29,31,28,31,30,31,30,31,31,30,31,30,31] // an array of the days in the month.  0 index is leap year February
            
            var newHour = hour
            var newDay = day
            var newMonth = month
            var newYear = year
            
           // let hourModifierB = 0
            
            println(timeOperator)
            
            switch timeOperator {
            case "-":
                newHour = (tempHour + hourModifier > 24 ? (tempHour+hourModifier)-24 : newHour)
                
            case "+":
                newHour = (tempHour - hourModifier < 0 ? 24+(tempHour - hourModifier) : newHour)
                
            default:
                // do stuff
                println("default!")
            }
            
            // Get the proper monthDays array index, accounting for leap year
            
            let monthIndex = (((Int(year) % 4 == 0) && (newMonth == 2)) ? 0 : newMonth)
            
            if tempHour > 24 {
                newDay += 1
                if newDay > monthDays[monthIndex] {
                    newMonth = 1 + (newMonth > 12 ? 0 : newMonth)
                    newDay = 1
                    newYear = newYear + (newMonth == 1 ? 1 : 0)
                }
            } else if tempHour < 0 {
                newDay -=  1
                if newDay < 1 {
                    newMonth = -1 + (newMonth < 1 ? 13 : newMonth)
                    newDay = monthDays[newMonth]
                    newYear = newYear - (newMonth == 12 ? 1 : 0)
                }
            }

            
            return (newYear, newMonth, newDay, newHour)
        }
        
        // break out the date and time pieces from the datetime string
        let year = noaaDate.substringToIndex(advance(noaaDate.startIndex, 4)).toInt()
        var slimmedStr = noaaDate
        slimmedStr = slimmedStr.substringFromIndex(advance(slimmedStr.startIndex, 5))
        let month = slimmedStr.substringToIndex(advance(slimmedStr.startIndex, 2)).toInt()
        slimmedStr = slimmedStr.substringFromIndex(advance(slimmedStr.startIndex, 3))
        let day = slimmedStr.substringToIndex(advance(slimmedStr.startIndex, 2)).toInt()
        slimmedStr = slimmedStr.substringFromIndex(advance(slimmedStr.startIndex, 3))
        let hour = slimmedStr.substringToIndex(advance(slimmedStr.startIndex, 2)).toInt()
        slimmedStr = slimmedStr.substringFromIndex(advance(slimmedStr.startIndex, 8))
        let timeOperator = slimmedStr.substringToIndex(advance(slimmedStr.startIndex, 1))
        slimmedStr = slimmedStr.substringFromIndex(advance(slimmedStr.startIndex, 1))
        let hourModifier = slimmedStr.substringToIndex(advance(slimmedStr.startIndex, 2)).toInt()
        let minuteModifier = slimmedStr.substringFromIndex(advance(slimmedStr.startIndex, 3)).toInt()

        let adjustedDateTime = timeZoneAdjust(Int(year!), Int(month!), Int(day!), Int(hour!), Int(hourModifier!), timeOperator)
        
        var dateFmt = NSDateFormatter()
        dateFmt.timeZone = NSTimeZone.localTimeZone()
        
        println(NSTimeZone.systemTimeZone().secondsFromGMT)
        
        dateFmt.dateFormat = format

        // It turns out the hour modifier seems to be used only to indicate offset, not require the adjustment.
//        let newreadableDate = userVisibleDateTimeStringForRFC3339DateTimeString(noaaDate)
        println(noaaDate)
       // let newreadableDate = dateFmt.dateFromString(noaaDate)
       // println(newreadableDate)
        
        let readableDate = "\(adjustedDateTime.newYear)-\(adjustedDateTime.newMonth)-\(adjustedDateTime.newDay) \(adjustedDateTime.newHour):00"
        println(readableDate)

        //let readableDate = "\(Int(year!))-\(Int(month!))-\(Int(day!)) \(Int(hour!)):00"
        let newReadableDate = dateFmt.dateFromString(readableDate)
        return newReadableDate!
        
    }
    
    func didCompleteWithXML(results: XMLIndexer) {
        // now that we have the data from NOAA, the hard work begins
        var earliestTime = results["dwml"]["data"]["time-layout"]["start-valid-time"][0].element?.text
        
        var earliestTimeNS = parseNOAADateTime(earliestTime!)
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitDay, fromDate: earliestTimeNS)
        let dayZero = components.day
        
        //var recordIndex = 0
        var subRecordIndex = 0
        var previousDayIndex = -1
        var windSpeedMPH = 0
        var windSpeedGustMPH = 0
        
        // we should check for results["dwml"]["data"]["time-layout"]["start-valid-time"][recordIndex] as the SWXMLHash documentation suggests, but that crashes when you test an array index one higher than should be allowed.  For now, sticking with 168 records (7 full days)
        for recordIndex in 0...167 {
            let tempDateTimeString = results["dwml"]["data"]["time-layout"]["start-valid-time"][recordIndex].element?.text
            let thisDateTime = parseNOAADateTime(tempDateTimeString!)
            let tempDateTimeComponents = calendar.components(.CalendarUnitDay, fromDate: thisDateTime)
            let tempDateMonthComponent = calendar.components(.CalendarUnitMonth, fromDate: thisDateTime)
            let tempDateYearComponent = calendar.components(.CalendarUnitYear, fromDate: thisDateTime)
            println(tempDateMonthComponent.month)

            let newCalendar = NSCalendar.currentCalendar()
            let newStuff = newCalendar.componentsInTimeZone(.defaultTimeZone(), fromDate: thisDateTime)
            
            /*
            HACK!
            
            Required becasue setting the date with the default timezone doesn't work!
            As a result, we have to force the issue
            */
            
           
            var forecastIndex = tempDateTimeComponents.day - dayZero
            
            
            println("ForecastIndex is \(forecastIndex) because tempDateTimeComponents.day is \(newStuff.day) based on \(thisDateTime) and dayZero is \(dayZero)")
            println("recordIndex is \(recordIndex)")

            /* 
                HACK!
            
                Required becasue setting the date with the default timezone doesn't work!
                As a result, we have to force the issue
            */
            println("forecastIndex is \(forecastIndex)")
            
            if forecastIndex < 0 {
                let monthDays = [29,31,28,31,30,31,30,31,31,30,31,30,31] // an array of the days in the month.  0 index is leap year February
                var monthIndex = 0
                println("year = \(tempDateYearComponent.year)")
                if (tempDateYearComponent.year % 4 == 0) && (tempDateMonthComponent.month == 3) {
                    println("seeting the month index to 0 - leap year")
                    monthIndex = 0
                } else {
                    println("setting the month index to last month")
                    monthIndex = tempDateMonthComponent.month - 1
                }
                if (tempDateYearComponent.year % 4 == 0) && (tempDateMonthComponent.month == 1) {
                    println("seeting the month index to December")
                    monthIndex = 12
                } else {
                    println("setting the month index to last month")
                    monthIndex = tempDateMonthComponent.month - 1
                }
               // println(tempDateTimeComponents.mo)
                println(monthIndex)
                forecastIndex = monthDays[monthIndex] - dayZero + tempDateTimeComponents.day
                //break
                println("forecastIndex is now \(forecastIndex)")
            }
            
            if recordIndex == 0 {
                if sevenDayForecast.count > 0 {
                    sevenDayForecast.removeAll(keepCapacity: false)
                }
            }
            
            if forecastIndex != previousDayIndex {
                subRecordIndex = 0
                previousDayIndex++
                sevenDayForecast.append(dailyForecast())
            } else {
                subRecordIndex++
            }

            sevenDayForecast[forecastIndex].forecastTime.append(thisDateTime)

            // dewpoint
            var tempDewPointF = results["dwml"]["data"]["parameters"]["temperature"][0]["value"][recordIndex].element?.text?.toInt()
            tempDewPointF = (tempDewPointF == nil ? 0 : tempDewPointF)
            let tempDewPointC = conversion.fahrenheitToCelsius(tempDewPointF!)
            
            sevenDayForecast[forecastIndex].dewPoint.append(["F": Int(tempDewPointF!), "C":Int(tempDewPointC)])
            
            // heat index
            // It turns out that NOAA will sometimes give no heat index when there should be one.  Need to calculate it.
            var tempHeatTempText = NSString(string:"0")
            if results["dwml"]["data"]["parameters"]["temperature"][2]["value"][recordIndex].element!.text != nil {
                tempHeatTempText = NSString(string: results["dwml"]["data"]["parameters"]["temperature"][2]["value"][recordIndex].element!.text!)
            }
            let tempHeatTempDouble = tempHeatTempText.doubleValue
            var tempHeatHumidtyText = NSString(string: "0")
            if results["dwml"]["data"]["parameters"]["humidity"]["value"][recordIndex].element!.text != nil {
                tempHeatHumidtyText = NSString(string: results["dwml"]["data"]["parameters"]["humidity"]["value"][recordIndex].element!.text!)
            }
            let tempHeatHumidityDouble = tempHeatHumidtyText.doubleValue
            let tempHeatIndex = feelsLike.calculateHeatIndex(tempHeatTempDouble, humidity: tempHeatHumidityDouble)
            sevenDayForecast[forecastIndex].heatIndex.append(["F": tempHeatIndex["F"]!, "C": tempHeatIndex["C"]!])
            
            if sevenDayForecast[forecastIndex].maxHeatIndex < sevenDayForecast[forecastIndex].heatIndex[subRecordIndex]["F"]! {
                sevenDayForecast[forecastIndex].maxHeatIndex = sevenDayForecast[forecastIndex].heatIndex[subRecordIndex]["F"]!
            }
            
            let whoa = sevenDayForecast[forecastIndex].heatIndex[subRecordIndex]["F"]
            println("For \(sevenDayForecast[forecastIndex].forecastTime[subRecordIndex]), the heat index is \(whoa).  The subRecordIndex is \(subRecordIndex).")
            

            // wind speed (sustained)
            if results["dwml"]["data"]["parameters"]["wind-speed"][0]["value"][recordIndex].element?.text?  != nil {
                let tempWindSpeedMPH = results["dwml"]["data"]["parameters"]["wind-speed"][0]["value"][recordIndex].element?.text?.toInt()
                windSpeedMPH = Int(tempWindSpeedMPH!)
                let tempWindSpeedKPH = conversion.milesToKilometers(tempWindSpeedMPH!)
                sevenDayForecast[forecastIndex].windSpeed.append(["MPH": Int(tempWindSpeedMPH!), "KPH":Int(tempWindSpeedKPH)])
            } else {
                sevenDayForecast[forecastIndex].windSpeed.append(["MPH": 0, "KPH":0])
            }
            
            // cloud amount (%)
            var tempCloudAmount = results["dwml"]["data"]["parameters"]["cloud-amount"]["value"][recordIndex].element?.text?.toInt()
            tempCloudAmount = (tempCloudAmount == nil ? 0 : tempCloudAmount)
            sevenDayForecast[forecastIndex].cloudAmount.append(tempCloudAmount!)
            
            // probability of precipitation (%)
            var tempPOP = results["dwml"]["data"]["parameters"]["probability-of-precipitation"]["value"][recordIndex].element?.text?.toInt()
            tempPOP = (tempPOP == nil ? 0 : tempPOP)
            sevenDayForecast[forecastIndex].probabilityOfPrecipitation.append(tempPOP!)
            
            // relative humidity (%)
            let tempHumidity = results["dwml"]["data"]["parameters"]["humidity"]["value"][recordIndex].element?.text?.toInt()
            if tempHumidity == nil {
                sevenDayForecast[forecastIndex].humidity.append(0)
            } else {
                sevenDayForecast[forecastIndex].humidity.append(tempHumidity!)
            }

            // wind direction (degrees)
            let tempDirection = results["dwml"]["data"]["parameters"]["direction"]["value"][recordIndex].element?.text?.toInt()
            sevenDayForecast[forecastIndex].windDirection.append(tempDirection!)
            
            // temperature
            var tempTemperatureF = results["dwml"]["data"]["parameters"]["temperature"][2]["value"][recordIndex].element?.text?.toInt()
            // **** Hack: sometimes the forecast temp can be nil.  Inserting - for now
            if tempTemperatureF == nil {
                tempTemperatureF = 0
            }
            let tempTemperatureC = conversion.fahrenheitToCelsius(tempTemperatureF!)
            sevenDayForecast[forecastIndex].temperature.append(["F": Int(tempTemperatureF!), "C":Int(tempTemperatureC)])

            // wind speed (gust)
            if results["dwml"]["data"]["parameters"]["wind-speed"][1]["value"][recordIndex].element?.text? != nil {
                let tempWindGustMPH = results["dwml"]["data"]["parameters"]["wind-speed"][1]["value"][recordIndex].element?.text?.toInt()
                windSpeedGustMPH = tempWindGustMPH!
                let tempWindGustKPH = conversion.milesToKilometers(tempWindGustMPH!)
                sevenDayForecast[forecastIndex].windSpeed.append(["MPH": Int(tempWindGustMPH!), "KPH":Int(tempWindGustKPH)])
            } else {
                sevenDayForecast[forecastIndex].windSpeed.append(["MPH": 0, "KPH":0])
            }
            // quantitative precipitation (inches) (hourly)
            // had trouble casting the string values to Double.  Hope to get this resolved at some time.
            
            // Wind chill: T(wc) = 35.74 + 0.6215T - 35.75(V0.16) + 0.4275T(V0.16)
            sevenDayForecast[forecastIndex].windChill.append(feelsLike.calculateWindChill(Double(tempTemperatureF!), windInMPH: Double(windSpeedMPH)))
            
            sevenDayForecast[forecastIndex].windChillGust.append(feelsLike.calculateWindChill(Double(tempTemperatureF!), windInMPH: Double(windSpeedGustMPH)))
            
            
            // Determine the minimum wind chill for the day.  Since gusts are stronger than sustatined winds, only windSpeedGust is used
            sevenDayForecast[forecastIndex].minWindChillF = (sevenDayForecast[forecastIndex].windChillGust[subRecordIndex]["F"]! < sevenDayForecast[forecastIndex].minWindChillF ? sevenDayForecast[forecastIndex].windChillGust[subRecordIndex]["F"]! : sevenDayForecast[forecastIndex].minWindChillF)
            sevenDayForecast[forecastIndex].minWindChillC = (sevenDayForecast[forecastIndex].windChillGust[subRecordIndex]["C"]! < sevenDayForecast[forecastIndex].minWindChillC ? sevenDayForecast[forecastIndex].windChillGust[subRecordIndex]["C"]! : sevenDayForecast[forecastIndex].minWindChillC)
            
            // Weather conditions
            // we should check for results["dwml"]["data"]["parameters"]["weather"]["weather-conditions"][recordIndex]["value"] as the SWXMLHash documentation suggests, but that crashes when you test an array index one higher than should be allowed.  For now, sticking with 2 records (2 weather conditions attributes)
            for weatherConditionsIndex in 0...1 {
                switch results["dwml"]["data"]["parameters"]["weather"]["weather-conditions"][recordIndex]["value"][weatherConditionsIndex] {
                case .Element(let elem):
                        let additive = (results["dwml"]["data"]["parameters"]["weather"]["weather-conditions"][recordIndex]["value"][weatherConditionsIndex].element?.attributes["additive"]? != nil ? results["dwml"]["data"]["parameters"]["weather"]["weather-conditions"][recordIndex]["value"][weatherConditionsIndex].element?.attributes["additive"] : "-")
                        let weatherType = results["dwml"]["data"]["parameters"]["weather"]["weather-conditions"][recordIndex]["value"][weatherConditionsIndex].element?.attributes["weather-type"]
                        sevenDayForecast[forecastIndex].weatherConditions.append(["additive": additive!, "weatherType": weatherType!])
                case .Error(let error):
                    //println("error!")
                    let errorText = "Error!"
                default:
                    println("Did this just happen?")
                }
            }
            

            // prepare for the next record
            windSpeedMPH = 0
            windSpeedGustMPH = 0

        }
        // Let the delegate know our work is done.
        self.delegate?.didCompleteForecast()
    }


    
    
    func didCompleteWithDictionary(results: NSDictionary) {
        // nothing to do here
    }
    
    func didCompleteWithError(errorMessage: String) {
        println("error!")
    }
    

    
}

infix operator  ** {}

func ** (num: Double, power: Double) -> Double{
    return pow(num, power)
}
