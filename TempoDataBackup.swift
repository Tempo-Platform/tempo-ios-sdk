//
//  TempoDataBackup.swift
//  TempoSDK
//
//  Created by Stephen Baker on 5/4/2023.
//

import Foundation

public class TempoDataBackup
{
    static let folderName: String = "metricJsons"
    static let fileSuffix: String = "_mtarr.tempo"
    
    // TODO:
    public static func sendData(dataArray: [Metric]?) {
        
        if(dataArray != nil)
        {
            // Create/get file subdirectory to store data
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let jsonDirectory = documentsDirectory.appendingPathComponent(folderName)
            do {
                try FileManager.default.createDirectory(at: jsonDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("❌ Error creating document directory: \(error.localizedDescription)")
                return
            }
            
            var nameList = "Saved files: "
            let encoder = JSONEncoder()
            do {
                // Encode metric array to JSON data object
                let jsonData = try encoder.encode(dataArray)
                
                // Create unique name using datetime
                var filename = String(Double(Date().timeIntervalSince1970))
                filename = filename.replacingOccurrences(of: ".", with: "_") + fileSuffix
                nameList += " - \(filename)"
                
                // Add metric arrays to device file storage
                let fileURL = jsonDirectory.appendingPathComponent(filename)
                try jsonData.write(to: fileURL)
                for metric in dataArray! {
                    nameList += "\n - \(metric.metric_type ?? "[type_undefined]")"
                }
            }
            catch{
                print("❌ Error either creating or saving JSON: \(error.localizedDescription)")
                return
            }
            
            // Displays entries being saved
            print("💥 \(nameList)")
        }
    }

    // TODO:
    public static func getData() -> [[Metric]]? {
        
        // To retrieve the data later, you can read the contents of the JSON directory using the FileManager class,
        // and then read the contents of each JSON file using the Data and JSONDecoder classes:
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let jsonDirectory = documentsDirectory.appendingPathComponent(folderName)
        
        guard let contents = try? FileManager.default.contentsOfDirectory(at: jsonDirectory, includingPropertiesForKeys: nil) else {
            return nil
        }
        
        var returningMetrics = [[Metric]]()
        for fileURL in contents {
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                
                // Individual metric objects
                let metricPayload = try decoder.decode([Metric].self, from: data)
                for metric in metricPayload
                {
                    print("💥 \(fileURL) => \(metric.metric_type ?? "UNKNOWN")")
                }
                returningMetrics.append(metricPayload)
                
            } catch let error {
                print("Error reading file at \(fileURL): \(error)")
                continue
            }
        }
        return returningMetrics
    }

    // Clears all references in the dedicated
    public static func clearData()  {
        let jsonDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(folderName)
        
        do {
            // Get the contents of the directory
            let contents = try FileManager.default.contentsOfDirectory(at: jsonDirectory, includingPropertiesForKeys: nil, options: [])

            // Iterate over the contents and remove each file
            for fileURL in contents {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            // Handle error
        }
    }
    
    
}
