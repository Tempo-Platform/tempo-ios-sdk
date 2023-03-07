//
//  UTCRetriever.swift
//  TempoSDKTester
//
//  Created by Stephen Baker on 2/3/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import TrueTime

public class TempoUtcRetriever{
    
    public static var ntpCtrl: TempoNtpController?
    
    ///  Find best result for acurate time, falling back on device time if others fails
    public static func getUTCTime(deviceTime: inout Bool) -> Int? {
        
        //monitoredOutput()

        let utcTimestampNTP: Int? = ntpCtrl?.getNtpDateTime()
        let utcTimestampREST: Int? = getUTCTimeRestAPI()
        let utcTimestampDevice: Int? = Int(NSDate().timeIntervalSince1970)
        
        print("\n⏰ NTP: \(utcTimestampNTP)" +
              "\n⏰ WEB: \(utcTimestampREST)" +
              "\n⏰ DEV: \(utcTimestampDevice)\n")
        
        // Rreturn device value if
        if(utcTimestampNTP != nil)
        {
            deviceTime = false
            return utcTimestampREST
        }
        else if(utcTimestampREST != nil)
        {
            deviceTime = false
            return utcTimestampREST
        }
        else
        {
            deviceTime = true
            return utcTimestampDevice
        }
    }
    
    /// Uses online REST API to get Unix time (not 100% reliable)
    private static func getUTCTimeRestAPI() -> Int? {
        // Declare URL
        guard let url = URL(string: "https://worldtimeapi.org/api/timezone/Etc/UTC") else { return nil }
        
        // Declare web request method
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
    
        // Varaibles for persisting data
        var unixtime: Int?
        var utcDateTime: String?
        
        // Create task
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            defer {
                semaphore.signal()
            }
            
            // Check for errors
            if let error = error {
                print("Error getting UTC time: \(error.localizedDescription)")
                return
            }
            
            // Confirm HTTP response is 2**
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                print("Invalid response or data received.")
                return
            }
            //print("🤖 Data received: \(String(data: data, encoding: .utf8) ?? "Unable to parse data")")
            
            // Parse returned data to a proxy struct object
            do {
                let ntpResponse = try JSONDecoder().decode(NTPResponse.self, from: data)
//                print("⏰ => UTC Int: \(ntpResponse.unixTime)")
//                print("⏰ => UTC DateTime: \(ntpResponse.utcDateTime)")
                unixtime = ntpResponse.unixTime * 1000
                utcDateTime = ntpResponse.utcDateTime
            } catch {
                print("Error decoding UTC time: \(error.localizedDescription)")
            }
        }
        
        task.resume()
        
        _ = semaphore.wait(timeout: .now() + 1.0) // wait up to 2 second for a reply

        return unixtime
    }
    
    /// Gets time from device (unreliable, vulnerable to user time/date changes)
    public static func getUTCTimeDevice() -> Int? {
        
        return Int(NSDate().timeIntervalSince1970 * 1000)
    }
    
    
    private static func monitoredOutput(){
        var utcTimestamp: Int?
        var timeTakenSoFar: Int?
        var startTime = Int(NSDate().timeIntervalSince1970 * 1000)
                
        // NTP
//        let utcTimestampNTP: Int? = getUTCTimeNTP()
//        timeTakenSoFar = Int(NSDate().timeIntervalSince1970 * 1000) - startTime
//        utcTimestamp = utcTimestamp == nil ? utcTimestampNTP: utcTimestamp
//        print("⏰ NTP: \(timeTakenSoFar ?? -1): \(utcTimestampNTP ?? -1)")
                
        // REST API
        startTime = Int(NSDate().timeIntervalSince1970 * 1000)
        let utcTimestampREST: Int? = getUTCTimeRestAPI()
        timeTakenSoFar = Int(NSDate().timeIntervalSince1970 * 1000) - startTime
        utcTimestamp = utcTimestamp == nil ? utcTimestampREST: utcTimestamp
        print("⏰ RST: \(timeTakenSoFar ?? -1): \(utcTimestampREST ?? -1)")
                
        // DEVICE
        startTime = Int(NSDate().timeIntervalSince1970 * 1000)
        let utcTimestampDevice: Int? = Int(NSDate().timeIntervalSince1970 * 1000)
        timeTakenSoFar = Int(NSDate().timeIntervalSince1970 * 1000) - startTime
        utcTimestamp = utcTimestamp == nil ? utcTimestampDevice: utcTimestamp
        print("⏰ DEV: \(timeTakenSoFar ?? -1): \(utcTimestampDevice ?? -1)")
    }
}

struct NTPResponse: Codable {
    let utcDateTime: String
    let unixTime: Int
    
    enum CodingKeys: String, CodingKey {
        case utcDateTime = "utc_datetime"
        case unixTime = "unixtime"
    }
}
