//
//  WeatherViewController.swift
//  DuashWeather
//
//  Created by Duale on 4/13/19.
//  Copyright © 2019 Duale. All rights reserved.
//

import UIKit
import CoreLocation  // allows us to tap into the GPS functionalities of the iphone : hope
// option key if u wanna get more information
// we addded  CLLocationManagerDelegate to conform to the location mager
// so that we use the apple coreloaction that has a lot GPS functionalities
import Alamofire
import SwiftyJSON

// inorder to use alamofire check the documentations : in this case we need a response

class WeatherViewController: UIViewController , CLLocationManagerDelegate , changeCityDelegate {
    
    //ConstantsLon
    // thsi below is the weather url we are using in our file that we are using
    // to get the weather model and it will be a string that we need to integrate
    
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "466d0e37d3561f7bb35c6a534d6ae114"
    
    
    //TODO: Declare instance variables here
    
    let locationManager = CLLocationManager()
    let  weatherDataModel = WeatherDataModel()
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO:Set up the location manager here.
        // we are setting the weather view controller as the delegate of the lccation manager
        locationManager.delegate = self
        // using accuracy Ris determined by what you want
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        // request for users to access their location when in use
        locationManager.requestWhenInUseAuthorization()
        
        // remember requestWhenInUseAuthorization() will not show anything unless you add
        // description pop-up and inorder to do that go the property list or info list
        // we add two new properties to the  info list
        // 1: privacy location usage description : then write the message you need to show
        // 2: privation location when in use description : then write the message you need to show
        // after that go the clima githup paste / copy the last code for use without needing https request and paste it in the infoplist source code below the last message above
        // Now start the method for updating and searching the location
        locationManager.startUpdatingLocation()
        // what happens next : after searching and updating for locations
        // this information is sent to weatherviewcontroller since it is a delegate
        // and we update : now go to the didupdateloaction part
        
        ChangeTextColor()
        
    }
     
    
    func getWeatherData ( url: String , parameters: [String : String]) {
        // how to use alamofire to make HTTP request and handle the response
        Alamofire.request (url, method: .get , parameters : parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success. Got the weather data")
                
                // IF our http request is successful : then we are heading this way : we need to
                // format and create a constant of type JSON
                //
                let weatherJSON : JSON = JSON(response.result.value!)
                print(weatherJSON)
                self.updateWeatherData(json: weatherJSON)
                
            } else {
                //                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Failed"
            }
            
        }
    }
    
    
    
    
   
    func updateWeatherData (json: JSON)  {
        // remember we are grabbing this from the JSON ALAMOFIRE we checked : You can print
        // we do optional binding instead of force unrapping the tempResult ! to make it error free
        // if we dont use the optional binding we are making grave mistake in case if the tempResult
        // gives us some incorrecr ansser
        if  let tempResult = json["main"]["temp"].double {
            weatherDataModel.tempreture = Int(tempResult - 273.25) // kelvin to degrees : JSON is in kelvin
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            updateUIWithWeatherData()
        } else {
            cityLabel.text = "Weather Unavailable"
        }
        
    }
    
    
    
    func updateUIWithWeatherData() {
        cityLabel.text = String(weatherDataModel.city)  // controll command space bar for degree
        temperatureLabel.text = String(weatherDataModel.tempreture) + "°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        updateWeatherOnColor()
    }

    //MARK: - Location Manager Delegate Methods
/***************************************************************/
    //Write the didUpdateLocations method here:
    // tells the delegate which is the weatherview controller that locations were set
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[locations.count - 1]
        // first thing first check if the location is valid
        if (location.horizontalAccuracy > 0 )  {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil   // for printing/updating the location ones
            print("longitude =  \(location.coordinate.longitude)  , latitude = \(location.coordinate.latitude)")
            // let us set some parameters where we need to send to openweathermaps.org
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            // create a dictionary where we need to set the openWeatherMao
            // the documentaions are not random : we got it from the open weather map
            let params : [String :  String] = ["lat" : latitude , "lon" : longitude , "appid" : APP_ID ]
            // TO MAKE THE HTTP REQUEST WE USE THE FOLLOWING CODE BELOW
            getWeatherData (url: WEATHER_URL , parameters: params)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // remember when the location manager  fails to gets the location : then it saves it into an error message
        cityLabel.text = "Location unavailable"
    }
    
    
   
    
    func userEnteredAnewCityName(city: String) {
        //        print(city)

        let params : [String : String] = ["q" : city , "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    
  
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    func ChangeTextColor() {
       cityLabel.textColor = UIColor.white
//       temperatureLabel.textColor = UIColor.red
        
    }
    
    func updateWeatherOnColor() {
        if (Int(weatherDataModel.tempreture) >= 28 ) {
           temperatureLabel.textColor = UIColor.red
        } else if (Int(weatherDataModel.tempreture) <= 14  && Int(weatherDataModel.tempreture) >= 0  ) {
            temperatureLabel.textColor = UIColor.white
        } else if (Int(weatherDataModel.tempreture) < 0) {
             temperatureLabel.textColor = UIColor.red
        }
    }

}



