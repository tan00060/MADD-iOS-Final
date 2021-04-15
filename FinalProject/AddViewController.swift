//
//  AddViewController.swift
//  FinalProject
//
//  Created by Michael Tan on 2020-12-13.
//  Copyright © 2020 Michael Tan. All rights reserved.
//

import UIKit
import CoreLocation


class AddViewController: UIViewController, CLLocationManagerDelegate {
    
    var jsonObjects: [String: [[String:Any]]]?
    var saveDictionary: [String: Any] = [:]
    var pushItemToServer: String?
    var latitude : Double?
    var longitude : Double?
    
    
    @IBOutlet weak var locationTitle: UITextField!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var arrivalDate: UIDatePicker!
    @IBOutlet weak var departureDate: UIDatePicker!
    
    
    
    //our save button.
    // we get our location and store it in a global value
    // we create a dictionary that will be used to push the data to the api
    // we call out post request that will push our data
    // when we push our data we will navigate back to our passport view
    @IBAction func saveButton(_ sender: Any) {
        
        if let location = myLocationManager.location {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
        }
        
        saveDictionary["title"] = locationTitle.text
        saveDictionary["description"] = descriptionText.text
        saveDictionary["arrival"] = String(arrivalDate.date.description.dropLast(9))
        saveDictionary["departure"] = String(departureDate.date.description.dropLast(9))
        
        if let newLatitude = latitude{
            saveDictionary["latitude"] = newLatitude
        }
        
        if let newLongitude = longitude{
            saveDictionary["longitude"] = newLongitude
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: saveDictionary, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8)
            let escapedJSONString = jsonString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            pushItemToServer = escapedJSONString
        }
        catch {
            print ("Converted error = \(error.localizedDescription)")
        }
        
        postRequest()
        navigationController?.popViewController(animated: true)
        
    }
    
    //asks user if they will enable location for use
    var myLocationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        myLocationManager.delegate = self
        myLocationManager.requestWhenInUseAuthorization()
    }
    
    
    //if use accepts start updating location
    //if user declines stop updating location
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch(CLLocationManager.authorizationStatus()) {
        case .restricted, .notDetermined, .denied :
            myLocationManager.stopUpdatingLocation()
        case .authorizedWhenInUse,  .authorizedAlways :
            myLocationManager.startUpdatingLocation()
        @unknown default:
            print("owo")
        }
    }
    
    //this is our post request
    //we take our postString and add it to the end of our url
    //this will push the new data to the api
    func postRequest(){
        if let postString = pushItemToServer {
            print("THIS IS MY ITEM \(postString)")
            
            let requestURL: URL = URL(string: "http://lenczes.edumedia.ca/mad9137/final_api/passport/create/?data=\(postString)")!
            
            var InfoRequest: URLRequest = URLRequest(url: requestURL)
            
            let authString = "tan00060"
            
            if let utf8String = authString.data(using: String.Encoding.utf8) {
                let base64String = utf8String.base64EncodedString(options: .init(rawValue: 0))
                InfoRequest.addValue("Basic_" +  base64String, forHTTPHeaderField: "my-authentication")
                
            }
            
            let mySession: URLSession = URLSession.shared
            let myTask = mySession.dataTask(with: InfoRequest, completionHandler: requestTask)
            myTask.resume()
            
        }
    }
    
    func requestTask (serverData: Data?, serverResponse: URLResponse?, serverError: Error?) -> Void{
        
        if serverError != nil {
            self.myCallback(responseString: "", error: serverError?.localizedDescription)
        }else{
            let result = String(data: serverData!, encoding: String.Encoding.utf8)!
            self.myCallback(responseString: result as String, error: nil)
        }
        
    }
    
    func myCallback(responseString: String, error: String?) {
        
        if error != nil {
            print("DATA LIST LOADING ERROR: " + error!)
        }else{
            print("DATA RECEIVED: " + responseString)
        }
        
    }
    
    
    
}
