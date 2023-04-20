import Foundation

public class TempoDataBackup
{
    public static var readyForCheck: Bool = true
    static var fileMetric: [URL: [Metric]] = [:]
    
    /// Public funciton to start retrieval of backup data
    public static func initCheck() {
        buildMetricArrays()
    }
    
    /// Adds Metric JSON array as data file to device's backup folder
    public static func sendData(metricsArray: [Metric]?) {
        
        if(metricsArray != nil)
        {
            // Declare file subdirectory to fetch data
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let jsonDirectory = documentsDirectory.appendingPathComponent(TempoConstants.METRIC_BACKUOP_FOLDER)
            do {
                try FileManager.default.createDirectory(at: jsonDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating document directory: \(error.localizedDescription)")
                return
            }
            
            let encoder = JSONEncoder()
            do {
                // Encode metric array to JSON data object
                let jsonData = try encoder.encode(metricsArray)
                
                // Create unique name using datetime
                var filename = String(Double(Date().timeIntervalSince1970))
                filename = filename.replacingOccurrences(of: ".", with: "_") +  TempoConstants.METRIC_BACKUP_SUFFIX
                
                // Create file URL to device storage
                let fileURL = jsonDirectory.appendingPathComponent(filename)
                
                // Add metric arrays to device file storage
                try jsonData.write(to: fileURL)
                
                // Output array details durign debugging
                if(TempoConstants.IS_DEBUGGING)
                {
                    let fileSize = try FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as? NSNumber
                    var nameList = "Saved files: \(filename) (\(fileSize?.intValue ?? 0 ) bytes)"
                    for metric in metricsArray! {
                        nameList += "\n - \(metric.metric_type ?? "[type_undefined]")"
                    }
                    print("📂 \(nameList)")
                }
            }
            catch{
                print("Error either creating or saving JSON: \(error.localizedDescription)")
                return
            }
            
        }
    }

    /// Checks device's folder allocated to metrics data and builds an array of metric arrays from it
    static func buildMetricArrays() {
        
        // Declare file subdirectory to store data
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let jsonDirectory = documentsDirectory.appendingPathComponent(TempoConstants.METRIC_BACKUOP_FOLDER)
        
        guard let contents = try? FileManager.default.contentsOfDirectory(at: jsonDirectory, includingPropertiesForKeys: nil) else {
            return
        }
        
        // Loop through backend metrics and add to static dictionary
        for fileURL in contents {
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                
                // Individual metric objects
                let metricPayload = try decoder.decode([Metric].self, from: data)
                for metric in metricPayload
                {
                    fileMetric[fileURL] = metricPayload
                    if(TempoConstants.IS_DEBUGGING)
                    {
                        print("📊 \(fileURL) => \(metric.metric_type ?? "UNKNOWN")")
                    }
                }
                
            } catch let error {
                print("Error reading file at \(fileURL): \(error)")
                continue
            }
        }
    }

    /// Uses parameter file URL to locate and remove the file from local backup folder
    public static func removeSpecificMetricList(backupUrl: URL) {
        let jsonDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(TempoConstants.METRIC_BACKUOP_FOLDER)
        
        do {
//            // Get the contents of the directory
//            let contents = try FileManager.default.contentsOfDirectory(at: jsonDirectory, includingPropertiesForKeys: nil, options: [])

            // Remove each file
            try FileManager.default.removeItem(at: backupUrl)
            
        } catch {
            print("Error while attempting to remove '\(backupUrl)' from backup folder: \(error)")
        }
    }
    
    /// Clears ALL references in the dedicated local backup folder
    static func clearAllData()  {
        let jsonDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(TempoConstants.METRIC_BACKUOP_FOLDER)
        
        do {
            // Get the contents of the directory
            let contents = try FileManager.default.contentsOfDirectory(at: jsonDirectory, includingPropertiesForKeys: nil, options: [])

            // Iterate over the contents and remove each file
            for fileURL in contents {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            print("Error while attempting to clear backup folder: \(error)")
        }
    }
}
