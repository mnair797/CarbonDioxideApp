//
//  GoogleSheetsIntegration.swift
//  CarbonDioxideApp
//
//  Created by Meenakshi Nair on 2/18/21.
//

import Foundation
//import Firebase
//import FirebaseFirestore
//import SwiftyJSON
//import Alamofire
class GoogleSheetsIntegration {
    static let collectionName = "CO2TestV01"
    static let feedbackRecordType="Feedback"
    static let co2sensorRecordType="SensorCO2"
    static let uploadURL="https://v1.nocodeapi.com/gprof/google_sheets/vDeUBDsYEElokSec?tabId=Sheet1"
    static let datetimeFormat="yyyy-MM-dd HH:mm"
    static var lastSensorUpdate="XX"
        
    static func getCurrentDateTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat=datetimeFormat
        let datev = Date()
        let datestr = dateFormatter.string(from:datev)
        return datestr
    }

    static func recordSensor(source:String,co2:Int,timestamp:String, tempF:Float, pressure:Int, humidity:Int,battery:Int) {
        //addToGoogleSheet(passedData: [source], recordType: co2sensorRecordType)
        //addToGoogleSheet(passedData: [source,co2], recordType: co2sensorRecordType)
        //addToGoogleSheet(passedData: [source,co2,tempF,pressure], recordType: co2sensorRecordType)
        //addToGoogleSheet(passedData: [source,co2,tempF,pressure,humidity,battery], recordType: co2sensorRecordType)
        addToGoogleSheet(passedData: [source,co2,tempF,pressure,humidity,battery,timestamp], recordType: co2sensorRecordType)
    }
    
    static func recordFeedback(_ s: String) {
        addToGoogleSheet(passedData: [s], recordType: feedbackRecordType)
    }

    static func addToGoogleSheet(passedData:[Encodable], recordType:String) {
        var dataArray=[Encodable]()
        let dateStr = getCurrentDateTime()
        dataArray.append(dateStr)
        dataArray.append(recordType)
        dataArray.append(LocationViewController.currentLocation?.coordinate.latitude ?? 0)
        dataArray.append(LocationViewController.currentLocation?.coordinate.longitude ?? 0)
        dataArray = dataArray + passedData
        let da1 = [dataArray]
        //let da2 = JSON(da1)
        let validJson = JSONSerialization.isValidJSONObject(da1)
        if(validJson != true) {
            print("Sorry. JSON is not valid")
        }
        //debugPrint("Calling the Google Sheets NoCodeAPI with parameters. Data=",passedData,"; da1=",da1)
        
        let url = URL(string: uploadURL)
        guard url != nil else {
            print("Error creating URL: ",uploadURL)
            return
        }
        //debugPrint("Google Sheet integration: Step 1")
        
        let session = URLSession.shared
        var request = URLRequest(url: url!)
        request.httpMethod = "POST" //set http method as POST
        //debugPrint("Google Sheet integration: Step 2")
        
        do {
            //debugPrint("Google Sheet integration: Step 3")
            request.httpBody = try JSONSerialization.data(withJSONObject: da1, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            //request.httpBody=da2
            //debugPrint("Google Sheet integration: Step 4")
        } catch let error {
            print("Failed Request HTTP Body:",error.localizedDescription)
        }
        //debugPrint("Google Sheet integration: Step 5")
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            //debugPrint("Google Sheet integration: Step 6")
            guard error == nil else {
                return
            }
            //debugPrint("Google Sheet integration: Step 7")
            guard let data = data else {
                return
            }
            //curl -X POST "https://v1.nocodeapi.com/gprof/google_sheets/vDeUBDsYEElokSec?tabId=Sheet1" -H  "accept: application/json" -H  "Content-Type: application/json" -d "[[\"abc\",\"def\"],[\"a123\",\"b123\"]]"
            
            //debugPrint("GoogleSheets call returned:",data)
            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print("Google Sheet add returned: ", json)
                    // handle json...
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
}

/*
 static func recordFeedback(_ s: String) {
 let db=Firestore.firestore()
 db.collection(collectionName).addDocument(data: ["currentDate":Date(),
 "recordType":feedbackRecordType,
 "comments":s])
 }
 */

