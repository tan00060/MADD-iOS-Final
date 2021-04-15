//
//  PassportTableViewController.swift
//  FinalProject
//
//  Created by Michael Tan on 2020-12-13.
//  Copyright © 2020 Michael Tan. All rights reserved.
//

import UIKit

class PassportTableViewController: UITableViewController {
    
    var jsonObjects: [String: [[String:Any]]]?
    
    //this reloads when we click the add button in addviewcontroller
    //so that our new data can be appended to the page.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        requestData()
    }
    
    
    //first load of the page.
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //our first fetch request where we set up the url
    //we pass in our user name as an auth.
    func requestData(){
        let requestUrl: URL = URL(string: "http://lenczes.edumedia.ca/mad9137/final_api/passport/read/")!
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
    
    //our call back function for our requestData function.
    //if we get back our data we will save it into our global variable jsonObjects
    //when we get our data back we will reload out tableview
    func myCallback(responseString: String, error: String?) {
        if error != nil {
            //            print("DATA LIST LOADING ERROR: " + error!)
        }else{
            //            print("DATA RECEIVED: " + responseString)
        }
        
        DispatchQueue.main.async {
            if let myData: Data = responseString.data(using: String.Encoding.utf8) {
                do {
                    self.jsonObjects = try JSONSerialization.jsonObject(with: myData, options: []) as? [String: [[String:Any]]]
                } catch let convertError {
                    print(convertError.localizedDescription)
                }
            }
            self.tableView.reloadData()
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    //checks our jsonObject and create that many cells
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var cellCount = 0
        if let jsonObj = jsonObjects?["locations"]{
            cellCount = jsonObj.count
        }
        
        return cellCount
    }
    
    
    //we take our global jsonObject
    //we append the title and id from our jsonObject into the cells.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "passportInfo", for: indexPath)
        
        if let jsonObj = jsonObjects?["locations"]{
            let dictionaryRow = jsonObj[indexPath.row] as [String:Any]
            let title = dictionaryRow["title"] as? String
            let id = dictionaryRow["id"] as? Int
            cell.textLabel?.text = title
            cell.detailTextLabel?.text = "\(id!)"
        }
        return cell
    }
    
    
    //allows us to edit our tableview to swipe left to delete.
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle{
        return .delete
    }
    
    
    //this is our delete tableview section
    //if the user clicks on delete
    //it will run our deleterow function and remove it from our api.
    //we delete the same one from our jsonObject and refresh our page.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if let jsonObjID = jsonObjects?["locations"]{
            let dictionaryRow = jsonObjID[indexPath.row] as [String:Any]
            let id = dictionaryRow["id"] as? Int
            deleteRow(id: "\(id!)")
        }
        
        if editingStyle == .delete {
            jsonObjects?["locations"]?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    //passes our data to our InfoViewController to be used there
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPassportInfo" {
            let nextVC = segue.destination as? InfoViewController
            let thisCell = sender as? UITableViewCell
            let getRow = tableView.indexPath(for: thisCell!)!.row
            
            if let passportID = jsonObjects?["locations"]{
                nextVC?.infoID = passportID[getRow]["id"] as? Int
            }
        }
    }
    
    
    
    //Our delete function
    //we fetch the url and auth it with our username
    //we pass in our id and remove it from the api.
    func deleteRow(id: String){
        let newId = String(id)
        let fetchURL = "http://lenczes.edumedia.ca/mad9137/final_api/passport/delete/?id=\(newId)"
        requestDeleteData(fetchURL: "\(fetchURL)")
    }
    
    func requestDeleteData(fetchURL: String){
        
        let requestUrl: URL = URL(string: fetchURL)!
        var InfoRequest: URLRequest = URLRequest(url: requestUrl)
        let authString = "tan00060"
        
        if let utf8String = authString.data(using: String.Encoding.utf8) {
            let base64String = utf8String.base64EncodedString(options: .init(rawValue: 0))
            InfoRequest.addValue("Basic_" +  base64String, forHTTPHeaderField: "my-authentication")
        }
        let InfoSession: URLSession = URLSession.shared
        let InfoTask = InfoSession.dataTask(with: InfoRequest, completionHandler: requestDeleteTask)
        InfoTask.resume()
    }
    
    func requestDeleteTask (serverData: Data?, serverResponse: URLResponse?, serverError: Error?) -> Void{
        
        if serverError != nil {
            myDeleteCallback(responseString: "", error: serverError?.localizedDescription)
        }else{
            let result = String(data: serverData!, encoding: String.Encoding.utf8)!
            myDeleteCallback(responseString: result as String, error: nil)
        }
        
    }
    
    func myDeleteCallback(responseString: String, error: String?) {
        
        if error != nil {
            print("DATA LIST LOADING ERROR: " + error!)
        }else{
            print("DATA RECEIVED: " + responseString)
        }
    }
    
    
    
}
