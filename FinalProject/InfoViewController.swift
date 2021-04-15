//
//  InfoViewController.swift
//  FinalProject
//
//  Created by Michael Tan on 2020-12-13.
//  Copyright © 2020 Michael Tan. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    
    var infoID: Int?
    var jsonObjects: [String:Any]?
    var fetchURL = "http://lenczes.edumedia.ca/mad9137/final_api/passport/read/?id="
    
    
    @IBOutlet weak var infoTitle: UILabel!
    @IBOutlet weak var infoLatValue: UILabel!
    @IBOutlet weak var infoLongValue: UILabel!
    @IBOutlet weak var infoArrivalValue: UILabel!
    @IBOutlet weak var infoDepartValue: UILabel!
    @IBOutlet weak var infoDescriptionValue: UITextView!
    

    
    //on load we will request the specific user data that we get from our infoID
    //info id is passed from our passport
    override func viewDidLoad() {
        super.viewDidLoad()
        requestData()
    }
    
    
    
    //our requestData function
    //takes our location id and add it to our api url where we will get the specific user.
    //in our callback function we will take the jsonObject and store it into a global variable
    //we then use the global variable to loop through and append our input fields with the correct values.
    func requestData(){
        
        if let locationID = infoID{
            fetchURL += "\(locationID)"
        }
        
        let requestUrl: URL = URL(string: fetchURL)!
        var InfoRequest: URLRequest = URLRequest(url: requestUrl)
        let authString = "tan00060"
        
        if let utf8String = authString.data(using: String.Encoding.utf8) {
            let base64String = utf8String.base64EncodedString(options: .init(rawValue: 0))
            InfoRequest.addValue("Basic_" +  base64String, forHTTPHeaderField: "my-authentication")
            
        }
        let InfoSession: URLSession = URLSession.shared
        let InfoTask = InfoSession.dataTask(with: InfoRequest, completionHandler: requestTask)
        InfoTask.resume()
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
            print("INFO DATA RECEIVED: " + responseString)
        }
        
        DispatchQueue.main.async {
            if let myData: Data = responseString.data(using: String.Encoding.utf8) {
                do {
                    self.jsonObjects = try JSONSerialization.jsonObject(with: myData, options: []) as? [String:Any]
                } catch let convertError {
                    print(convertError.localizedDescription)
                }
            }
            
            if let infoObjectTitle = self.jsonObjects?["title"]{
                self.infoTitle.text = infoObjectTitle as? String
            }
            
            if let infoObjectLat = self.jsonObjects?["longitude"]{
                print(infoObjectLat)
                self.infoLongValue.text = "\(infoObjectLat)"
            }
            
            if let infoObjectLong = self.jsonObjects?["latitude"]{
                self.infoLatValue.text = "\(infoObjectLong)"
            }
            
            if let infoObjectArrival = self.jsonObjects?["arrival"]{
                self.infoArrivalValue.text = infoObjectArrival as? String
            }
            
            if let infoObjectDepart = self.jsonObjects?["departure"]{
                self.infoDepartValue.text = infoObjectDepart as? String
            }
            
            if let infoObjectText = self.jsonObjects?["description"]{
                self.infoDescriptionValue.text = infoObjectText as? String
            }
            
        }
        

    }
    
    
    
}
