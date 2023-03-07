//
//  TempoNtpController.swift
//  Pods
//
//  Created by Stephen Baker on 7/3/2023.
//

import Foundation
import TrueTime

public class TempoNtpController {
    
    var client: TrueTimeClient?
    
    public init() {
        print("NtpClient Initialised")
    }
    
    /// Sets up initial NTP client which will be used throughout the session
    /// See https://cocoapods.org/pods/TrueTime for implementation descroption
    public func createClient(delegate: @escaping () -> Void)
    {
        let startTime = NSDate().timeIntervalSince1970
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
                        print("Time = \(now) [\(NSDate().timeIntervalSince1970 - startTime)]")
                        delegate()
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
    
    /// Returns a unix timestamp integer from first available NTP server
    func getNtpDateTime() -> Int? {
        
        let datetime = client?.referenceTime?.now()

        if(datetime == nil)
        {
            return nil
        }
        
        return Int(datetime!.timeIntervalSince1970) * 1000
    }
    
    /// Converts Date object into formatted String for readability
    func getDateString(dateTime: Date) -> String {
        
        var dtString: String = "???"
        
        // Create Date Formatter
        let dateFormatter = DateFormatter()

        // Set Date Format
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
        
        // Convert Date to String
        dtString = dateFormatter.string(from: dateTime)
        
        // Uncomment/edit this if you want to append the unix timestamp to it
        //dtString += "\r\n \(Int(dateTime.timeIntervalSince1970))"
               
        return dtString
    }
}
