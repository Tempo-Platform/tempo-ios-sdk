import Foundation
import TrueTime

public class TempoUtcGenerator{
    
    let debugging: Bool = false // make true for console outputs
    
    public init() {
        TempoNtpController.createClient(delegate: monitoredOutput)
    }
    
    ///  Find best result for acurate time, falling back on device time if others fails
    public func getUTCTime(deviceTime: inout Bool) -> Int? {
        
        let utcTimestampNTP: Int? = TempoNtpController.getNtpDateTime()
        if(utcTimestampNTP != nil)
        {
            if(debugging) { print("🍏 NTP -> \(utcTimestampNTP!)") }
            deviceTime = false
            return utcTimestampNTP
        }
        
        let utcTimestampREST: Int? = getUTCTimeRestAPI()
        if(utcTimestampREST != nil)
        {
            if(debugging) { print("🍌 REST -> \(utcTimestampREST!)") }
            deviceTime = false
            return utcTimestampREST
        }
        
        if(debugging) { print("🍓 DEVICE -> \(getUTCTimeDevice())") }
        // Fall back on device tim
        deviceTime = true
        return getUTCTimeDevice()
    }
    
    /// Uses online REST API to get Unix time (not 100% reliable)
    private func getUTCTimeRestAPI() -> Int? {
        
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
            
            defer { semaphore.signal() }
            
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
        
        _ = semaphore.wait(timeout: .now() + 2.0) // wait up to 2 second for a reply
        
        return unixtime
    }
    
    /// Gets time from device (unreliable, vulnerable to user time/date changes)
    public func getUTCTimeDevice() -> Int {
        
        return Int(NSDate().timeIntervalSince1970 * 1000)
    }
    
    /// Debugging tool to check date version status
    private func monitoredOutput(){
        
        if(debugging)
        {
            let checkpointA = NSDate().timeIntervalSince1970
            let utcTimestampNTP: Int? = TempoNtpController.getNtpDateTime()
            let checkpointB = NSDate().timeIntervalSince1970
            let utcTimestampREST: Int? = getUTCTimeRestAPI()
            let checkpointC = NSDate().timeIntervalSince1970
            let utcTimestampDevice: Int? = Int(NSDate().timeIntervalSince1970) * 1000
            
            print("⏰ Initial check:" +
                  "\n - NTP: \(utcTimestampNTP == nil ? "n/a" : String(utcTimestampNTP!)) [\(checkpointB - checkpointA)]" +
                  "\n - WEB: \(utcTimestampREST == nil ? "n/a" : String(utcTimestampREST!)) [\(checkpointC - checkpointB)]" +
                  "\n - DEV: \(utcTimestampDevice == nil ? "n/a" : String(utcTimestampDevice!))")
        }
    }
    
    /// If set time has passed after specified time, resyncs NTP time delta
    public func resyncNtp() {
        //TempoNtpController.client?.pause()
        TempoNtpController.createClient(delegate: monitoredOutput)
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
