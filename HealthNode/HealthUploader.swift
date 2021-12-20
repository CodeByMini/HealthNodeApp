//
//  HealthUploader.swift
//  HealthNode
//
//  Created by Daniel Johansson on 2021-12-02.
//

import Foundation
import HealthKit
import Alamofire
import UIKit

func HealthPermission(){
    let healthStore = HKHealthStore()
    
    if HKHealthStore.isHealthDataAvailable() {
        let readData = Set([
            HKObjectType.quantityType(forIdentifier: .heartRate)!
        ])
        
        healthStore.requestAuthorization(toShare: [], read: readData) { (success, error) in
            if success {
                print("GREAT SUCCESS")
            }
            else{
                print("DAMMIT")
            }
        }
    }}


func HealthUpload(statusLabel: UILabel,
                  textField: UITextView,
                  hostInput:UITextField,
                  apikeyInput: UITextField,
                  nightscoutInput: UITextField) {
    let hostInput: String = hostInput.text!
    let apikey: String = apikeyInput.text!
    let nightscout: String = nightscoutInput.text!
    let deviceID = UIDevice.current.identifierForVendor!.uuidString
       print(deviceID)
    
    let healthStore = HKHealthStore()
    
    if HKHealthStore.isHealthDataAvailable() {
        let readData = Set([
            HKObjectType.quantityType(forIdentifier: .heartRate)!
        ])
        
        healthStore.requestAuthorization(toShare: [], read: readData) { (success, error) in
            if success {
                
                DispatchQueue.main.async{
                statusLabel.text = "Collecting Data..."
                }
                let calendar = NSCalendar.current
                
                var anchorComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: NSDate() as Date)
                
                let offset = (7 + anchorComponents.weekday! - 2) % 7
                
                anchorComponents.day! -= offset
                anchorComponents.hour = 2
                
                guard let anchorDate = Calendar.current.date(from: anchorComponents) else {
                    fatalError("*** unable to create a valid date from the given components ***")
                }
                
                let interval = NSDateComponents()
                interval.minute = 5
                
                let endDate = Date()
                
                guard let startDate = calendar.date(byAdding: .day, value: -2, to: endDate) else {
                    fatalError("*** Unable to calculate the start date ***")
                }
                
                guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
                    fatalError("*** Unable to create a step count type ***")
                }
                
                let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                        quantitySamplePredicate: nil,
                                                        options: .discreteAverage,
                                                        anchorDate: anchorDate,
                                                        intervalComponents: interval as DateComponents)
                
                query.initialResultsHandler = {
                    query, results, error in
                    
                    guard let statsCollection = results else {
                        fatalError("*** An error occurred while calculating the statistics: \(String(describing: error?.localizedDescription)) ***")
                    }
                    
                    var requestParams: [[String: Any]] = []
                    statsCollection.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
                        if let quantity = statistics.averageQuantity() {
                            let date = statistics.startDate
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "YY/MM/dd HH:mm:ss"
                            let fordate = dateFormatter.string(from: date)
                            let value = quantity.doubleValue(for: HKUnit(from: "count/min"))
                            var result: [String: Double] = [:]
                            result[fordate] = value
                            let parameters = ["date":date.timeIntervalSince1970,"value":value, "device":deviceID, "nightscout": nightscout] as [String : Any]
                            requestParams.append(parameters)
                        }
                    }
                    DispatchQueue.main.async{
                    statusLabel.text = "Uploading Data..."
                    }
                   
                    
                    let hosturl = hostInput
                    
                    let param = ["apikey": apikey] as [String : Any]

                    AF.request(hosturl+"api/"+deviceID, method: .delete, parameters: param).response{ response in
                    }
                    //let url = URL(string: "http://192.168.1.26:3333/api/"+deviceID)
                    let url = URL(string: hosturl+"api/"+deviceID)
                    var request = URLRequest(url: url!)
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue(apikey, forHTTPHeaderField: "apikey")
                    request.httpMethod = "POST"
                    request.httpBody = try! JSONSerialization.data(withJSONObject: requestParams, options: [])
                    AF.request(request).response { (response) in
                                print(response)
                                switch response.result {
                                case .success:
                                    print(response.result)
                                    print("done")
                                    DispatchQueue.main.async{
                                    statusLabel.text = "Uploaded, Ready"
                                        UIApplication.shared.openURL(NSURL(string:hosturl+deviceID+"?ns="+nightscout)! as URL)
                                    }
                                    break
                                case .failure:
                                    print(response.result)
                                    print("failed")
                                    DispatchQueue.main.async{
                                    statusLabel.text = "Not Uploaded"
                                    }
                                    break
                                }
                            }
                    
                }
                healthStore.execute(query)
            } else {
                print("Authorization failed")
            }
        }
    }
}
