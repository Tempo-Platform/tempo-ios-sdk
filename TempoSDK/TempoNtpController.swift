import Foundation
import TrueTime

public class TempoNtpController {
    
    static var client: TrueTimeClient?
    static var fetching: Bool = false
    static var debugging: Bool = false // make true for console outputs
    
    /// Sets up initial NTP client which will be used throughout the session
    /// See https://cocoapods.org/pods/TrueTime for implementation descroption
    public static func createClient(delegate: @escaping () -> Void) {
        
        if(fetching)
        {
            if(debugging) { print("⚠️ Ignored: currently fetching") }
            return
        }
        
        let startTime = NSDate().timeIntervalSince1970
        if(client != nil)
        {
            client?.pause()
        }
        else
        {
            // At an opportune time (e.g. app start):
            client = TrueTimeClient.sharedInstance
        }
        
        if(client != nil)
        {
            client!.start()
            
            if(debugging) { print("✅ Start fetching") }
            fetching = true
            
            // To block waiting for fetch, use the following:
            client!.fetchIfNeeded(completion: {
                result in
                switch result
                {
                    case let .success(referenceTime):
                        if(debugging) {
                            print("NTPTime = \(referenceTime.now()) " + "[\(NSDate().timeIntervalSince1970 - startTime)]")
                        }
                        delegate()
                    case let .failure(error):
                        print("Error! \(error)")
                }
                if(debugging) { print("❌ End fetching") }
                fetching = false
            })
        }
        else
        {
            print("TrueTime client is nil!")
        }
    }
    
    /// Returns a unix timestamp integer from first available NTP server
    public static func getNtpDateTime() -> Int? {
        
        let datetime = client?.referenceTime?.now()

        if(datetime == nil) { return nil }
        
        return Int(datetime!.timeIntervalSince1970) * 1000
    }
    
    /// Converts Date object into formatted String for readability
    static func getDateString(dateTime: Date) -> String {
        
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
