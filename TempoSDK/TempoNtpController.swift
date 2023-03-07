//
//  TempoNtpController.swift
//  Pods
//
//  Created by Stephen Baker on 7/3/2023.
//

import Foundation
import TrueTime

public class TempoNtpController {
    
    var startDT: Double?
    var client: TrueTimeClient?
    
    public init() {
        startDT = NSDate().timeIntervalSince1970
        print("NtpClient Initialised")
    }
    
    public func createClient()
    {
        // At an opportune time (e.g. app start):
        client = TrueTimeClient.sharedInstance
        if(client != nil)
        {
            client!.start()
            
            // To block waiting for fetch, use the following:
            client!.fetchIfNeeded(completion: {
                result in
                switch result
                {
                    case let .success(referenceTime):
                        let now = referenceTime.now()
                        print("Time = \(now) [\(NSDate().timeIntervalSince1970 - self.startDT!)]")
                    case let .failure(error):
                        print("Error! \(error)")
                }
            })
        }
        else
        {
            print("TrueTime client is ni!")
        }
    }
    
    
    func getNtpDateTime() -> Int? {
        
        var datetime = client?.referenceTime?.now()
        
        if(datetime == nil)
        {
            return nil
        }
        return Int(datetime!.timeIntervalSince1970)
        
    }
    
    
    
    func getNewDt() -> String {
        
        var returnDate: String?
        
        returnDate = getDateString(dateTime: (client?.referenceTime?.now())!)
        
        return returnDate ?? "No NTP time available"
    }
    
    
    func getDeviceDt() -> String {
        var returnDt: String
        
        let deviceDtDbl: Double = NSDate().timeIntervalSince1970
        
        // Convert Double to Date
        let date = Date(timeIntervalSince1970: deviceDtDbl)
        
        // Create Date Formatter
        let dateFormatter = DateFormatter()

        // Set Date Format
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
        
        // Convert Date to String
        returnDt = dateFormatter.string(from: date)
        
        returnDt += "\r\n \(Int(deviceDtDbl))"
                
        return returnDt
    }
    
    func getDateString(dateTime: Date) -> String {
        
        var dtString: String = "???"
        
        // Create Date Formatter
        let dateFormatter = DateFormatter()

        // Set Date Format
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
        
        // Convert Date to String
        dtString = dateFormatter.string(from: dateTime)
        
        dtString += "\r\n \(Int(dateTime.timeIntervalSince1970))"
               
        return dtString
    }
    
    
}
