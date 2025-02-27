import Foundation
import CoreLocation

public class TempoProfile: NSObject, CLLocationManagerDelegate { //TODO: Make class internal/private/default(none)?
    
    // This instance's location manager delegate
    let locManager = CLLocationManager() //TODO: Does this do anything in instantiation?
    let requestOnLoad_testing = false
    let adView: TempoAdView
    
    // The static that can be retrieved at any time during the SDK's usage
    static var outputtingLocationInfo = false
    static var locationState: LocationState = LocationState.UNCHECKED
    var locData: LocationData = LocationData()
    var initialLocationRequestDone: Bool = false
    
    // First steps when instantiated
    init(adView: TempoAdView) {
        self.adView = adView
        super.init()
        TempoUtils.Say(msg: "🌟🌟🌟🌟🌟🌟🌟 TempoProfile INIT")
        
        // Assign manager delegate
        locManager.delegate = self
        
        // No point proceeding if already disabled
        if(TempoProfile.locationState == LocationState.DISABLED)
        {
            TempoUtils.Warn(msg: "🌏👨‍🦽‍➡️ LocationState.DISABLED (TempoProfile.init)")
            locData = LocationData()
            return
        }
        
        // Update locData with backup if nil
        do {
            locData = try TempoDataBackup.getLocationDataFromCache()
            initialLocationRequestDone = true
        } catch {
            TempoUtils.Warn(msg: "Error while attempting to fetch cached location data during init")
            locData = LocationData()
        }
        
        // Assign level of accuracy we want to start off with
        locManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        // For testing, loads when initialised // TODO: Move this now?
        if(requestOnLoad_testing) {
            locManager.requestWhenInUseAuthorization()
            locManager.requestLocation()
            requestLocationWithChecks()
        }
    }
    
    /// Makes a location request, updates locationState to CHECKING
    private func requestLocationWithChecks() {
        // No loc request if disabled
        if(TempoProfile.locationState == LocationState.DISABLED)
        {
            TempoUtils.Warn(msg: "🌏👨‍🦽‍➡️ LocationState.DISABLED (TempoProfile.requestLocationWithChecks)")
            return
        }
        // No loc request if already checking
        else if (TempoProfile.locationState == .CHECKING) {
            TempoUtils.Say(msg: "Ignoring request location as LocationState == CHECKING")
        }
        // Proceed with request and update state
        else {
            TempoProfile.updateLocState(newState: .CHECKING)
            locManager.requestLocation()
        }
    }
        
    /// Runs async thread process that gets authorization type/accuray and updates LocationData when received
    public func doTaskAfterLocAuthUpdate(completion: (() -> Void)?) {
        
        // CLLocationManager.authorizationStatus can cause UI unresponsiveness if invoked on the main thread.
        DispatchQueue.global().async {
            
            // Ignore and go straight to completion task if LocState disabled
            if(TempoProfile.locationState == LocationState.DISABLED)
            {
                TempoUtils.Warn(msg: "🌏👨‍🦽‍➡️ LocationState.DISABLED (TempoProfile.doTaskAfterLocAuthUpdate)")
                self.updateLocConsentValues(consentType: Constants.LocationConsent.NONE)
                completion?()
                return
            }
            
            // Make sure location services are available
            guard CLLocationManager.locationServicesEnabled() else {
                DispatchQueue.main.async {
                    TempoUtils.Warn(msg: "⛔️ Location services not enabled [UPDATE]")
                    TempoProfile.updateLocState(newState: LocationState.UNAVAILABLE)
                    self.updateLocConsentValues(consentType: Constants.LocationConsent.NONE)
                    completion?()
                }
                return
            }
            
            // Get authorization status
            let authStatus = self.getLocAuthStatus()
            
            switch authStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                DispatchQueue.main.async {
                    TempoUtils.Say(msg: "✅ Access - always or authorizedWhenInUse [UPDATE]")
                    if #available(iOS 14.0, *) {
                        // iOS 14 introduced precise/general options
                        if self.locManager.accuracyAuthorization == .reducedAccuracy {
                            self.handleAuthorizedLocAccess(.GENERAL, completion: completion)
                        } else {
                            self.handleAuthorizedLocAccess(.PRECISE, completion: completion)
                        }
                    } else {
                        // Pre-iOS 14: always treat as precise
                        self.handleAuthorizedLocAccess(.PRECISE, completion: completion)
                    }
                }
            case .restricted, .denied, .notDetermined:
                DispatchQueue.main.async {
                    switch authStatus {
                    case .restricted, .denied:
                        TempoUtils.Warn(msg: "⛔️ No access - restricted or denied [UPDATE]")
                    case .notDetermined:
                        TempoUtils.Warn(msg: "⛔️ No access - notDetermined [UPDATE]")
                    default:
                        break
                    }
                    self.handleNoAccessUpdate(completion: completion)
                }
            @unknown default:
                DispatchQueue.main.async {
                    TempoUtils.Warn(msg: "⛔️ Unknown authorization status [UPDATE]")
                }
            }
        }
    }
    
    /// Behaviour when location access returns as authorizedAlways/authorizedWhenInUse
    private func handleAuthorizedLocAccess(_ consentType: Constants.LocationConsent, completion: (() -> Void)?) {
        TempoUtils.Say(msg: "Updating LocationData consent as \(consentType.rawValue)")
        self.updateLocConsentValues(consentType: consentType)
        completion?()
    }
    
    /// Behaviour when location access returned is NOT authorizedAlways/authorizedWhenInUse
    private func handleNoAccessUpdate(completion: (() -> Void)?) {
        if(TempoProfile.locationState == LocationState.DISABLED)
        {
            TempoUtils.Warn(msg: "🌏👨‍🦽‍➡️ LocationState.DISABLED (TempoProfile.handleNoAccessUpdate)")
            locData = LocationData()
        } else {
            locData = self.adView.getClonedAndCleanedLocation()
        }
        
        TempoProfile.updateLocState(newState: LocationState.UNAVAILABLE)
        self.updateLocConsentValues(consentType: Constants.LocationConsent.NONE)
        self.saveLatestValidLocData()
        completion?()
    }
    
    // Updates consent value to both the static object and the adView instance string reference
    private func updateLocConsentValues(consentType: Constants.LocationConsent) {
        locData.consent = consentType.rawValue
        if(TempoProfile.outputtingLocationInfo) {
            TempoUtils.Say(msg: "✍️ Updated location consent to: \(consentType.rawValue)")
        }
    }
    
    /// Get CLAuthorizationStatus location consent value
    private func getLocAuthStatus() -> CLAuthorizationStatus {
        var locationAuthorizationStatus : CLAuthorizationStatus
        
        if #available(iOS 14.0, *) {
            locationAuthorizationStatus =  locManager.authorizationStatus
        } else {
            // Fallback for earlier versions
            locationAuthorizationStatus = CLLocationManager.authorizationStatus()
        }
        
        return locationAuthorizationStatus
    }
    
    /// Shortcut output for location property types while returning string refererence for metrics
    func getLocationPropertyValue(labelName: String, property: String?) -> String? {
        // TODO: Work out the tabs by string length..?
        if let checkedValue = property {
            if(TempoProfile.outputtingLocationInfo) {
                TempoUtils.Say(msg: "📍👍 \(labelName): \(checkedValue)")
            }
            return checkedValue
        }
        else {
            if(TempoProfile.outputtingLocationInfo) {
                TempoUtils.Say(msg: "📍👎 \(labelName): [UNAVAILABLE]")
            }
            return nil
        }
    }
    
    /// Shortcut output for location property types while returning string refererence for metrics
    func getLocationPropertyValue(labelName: String, property: [String]?) -> [String]? {
        // TODO: Work out the tabs by string length..?
        if let checkedValue = property {
            for prop in property! {
                if(TempoProfile.outputtingLocationInfo) {
                    TempoUtils.Say(msg: "📍👍 \(labelName): \(prop)")
                }
            }
            return checkedValue
        }
        else {
            if(TempoProfile.outputtingLocationInfo) {
                TempoUtils.Say(msg: "📍👎 \(labelName): [UNAVAILABLE]")
            }
            return nil
        }
    }
   
    /// Updates the fetching state of location data
    public static func updateLocState(newState: LocationState) {
        TempoProfile.locationState = newState
        
        if(TempoProfile.outputtingLocationInfo) {
            TempoUtils.Say(msg: "🗣️ Updated location state to: \(newState.rawValue)")
        }
    }
    
    /* ---------- Location Manager Callback ---------- */
    /// Location Manager callback: didChangeAuthorization
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        var updating = "NOT UPDATING"
        
        // Not likely to reach here if disabled - but handled jsut in case
        if(TempoProfile.locationState == LocationState.DISABLED) {
            TempoUtils.Warn(msg: "🌏👨‍🦽‍➡️ LocationState.DISABLED (TempoProfile.locationManager [delegate callback])")
        }
        // If authorisation checks out, proceed with update
        else if status == .authorizedWhenInUse || status == .authorizedAlways {
            if(TempoProfile.locationState != .CHECKING) {
                updating = "UPDATING"
                doTaskAfterLocAuthUpdate(completion: nil)
            } else {
                updating = "NOT UPDATING WHILE CHECKING"
            }
            
            requestLocationWithChecks()
            TempoUtils.Say(msg: "✅ didChangeAuthorization => \((status as CLAuthorizationStatus).rawValue): \(updating)")
            return
        }
        // The latest change (or first check) showed no valid authorisation
        else{
            TempoUtils.Say(msg: "❌ didChangeAuthorization => \((status as CLAuthorizationStatus).rawValue): \(updating)")
            TempoProfile.updateLocState(newState: LocationState.UNAVAILABLE)
            adView.checkSessionInitialRequestDone()
        }
        
        // Make consent state NONE
        self.updateLocConsentValues(consentType: Constants.LocationConsent.NONE)
    }
    
    /// Location Manager callback: didUpdateLocations
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            TempoUtils.Warn(msg: "☎️ didUpdateLocations: No valid locations found")
            TempoProfile.updateLocState(newState: LocationState.FAILED)
            adView.pushHeldMetricsWithUpdatedLocationData()
            return
        }
        
        // Reverse geocoding to get the location properties
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                TempoUtils.Warn(msg: "Reverse geocoding failed with error: \(error.localizedDescription) | Values remain unchanged")
                TempoProfile.updateLocState(newState: LocationState.FAILED)
                self.adView.pushHeldMetricsWithUpdatedLocationData()
            } else if let placemark = placemarks?.first {
                self.locData.state = self.getLocationPropertyValue(labelName: "State", property: placemark.administrativeArea)
                self.locData.postcode = self.getLocationPropertyValue(labelName: "Postcode", property: placemark.postalCode)
                self.locData.postal_code = self.getLocationPropertyValue(labelName: "Postal Code", property: placemark.postalCode)
                self.locData.country_code = self.getLocationPropertyValue(labelName: "Country Code", property: placemark.isoCountryCode)
                self.locData.admin_area = self.getLocationPropertyValue(labelName: "Admin Area", property: placemark.administrativeArea)
                self.locData.sub_admin_area = self.getLocationPropertyValue(labelName: "Sub Admin Area", property: placemark.subAdministrativeArea)
                self.locData.locality = self.getLocationPropertyValue(labelName: "Locality", property: placemark.locality)
                self.locData.sub_locality = self.getLocationPropertyValue(labelName: "Sub Locality", property: placemark.subLocality)
                
                // Update current session's top-level country code parameter if there is a value
                if let countryCode = self.locData.country_code, !countryCode.isEmpty {
                    self.adView.countryCode = countryCode
                }
                
                TempoUtils.Say(msg: "☎️ didUpdateLocations: [state/admin=\(self.locData.admin_area ?? "nil")] | Values have been updated")
                
                // Save data instance as the most recently validated data
                self.saveLatestValidLocData()
                TempoProfile.updateLocState(newState: LocationState.CHECKED)
                self.adView.pushHeldMetricsWithUpdatedLocationData()
    
            } else {
                TempoUtils.Warn(msg: "No placemarks found")
                TempoProfile.updateLocState(newState: LocationState.FAILED)
                self.adView.pushHeldMetricsWithUpdatedLocationData()
            }
            self.adView.checkSessionInitialRequestDone()
        }
    }
    
    // Save the instance to UserDefaults
    private func saveLatestValidLocData() {
        
        let encoder = JSONEncoder()
        do {
            // Encode locData to JSON
            let encoded = try encoder.encode(locData)
            
            // Save encoded data to UserDefaults
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: Constants.Backup.LOC_BACKUP_REF)
            
            TempoUtils.Say(msg: "Backup location data saved")
        } catch {
            // Handle encoding errors
            TempoUtils.Warn(msg: "Failed to encode and save location data: \(error.localizedDescription)")
        }
    }
    
    /// Location Manager callback: didFailWithError
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        TempoUtils.Say(msg: "☎️ didFailWithError: \(error)")
        //locManager.stopUpdatingLocation()
        
        if let clErr = error as? CLError {
            switch clErr.code {
            case .locationUnknown, .denied, .network:
                TempoUtils.Warn(msg: "Location request failed with error: \(clErr.localizedDescription)")
            case .headingFailure:
                TempoUtils.Warn(msg: "Heading request failed with error: \(clErr.localizedDescription)")
            case .rangingUnavailable, .rangingFailure:
                TempoUtils.Warn(msg: "Ranging request failed with error: \(clErr.localizedDescription)")
            case .regionMonitoringDenied, .regionMonitoringFailure, .regionMonitoringSetupDelayed, .regionMonitoringResponseDelayed:
                TempoUtils.Warn(msg: "Region monitoring request failed with error: \(clErr.localizedDescription)")
            default:
                TempoUtils.Warn(msg: "Unknown location manager error: \(clErr.localizedDescription)")
            }
        } else {
            TempoUtils.Warn(msg: "Unknown error occurred while handling location manager error: \(error.localizedDescription)")
        }
        
        // Need to start pushing these for this round
        TempoProfile.updateLocState(newState: LocationState.FAILED)
        self.adView.pushHeldMetricsWithUpdatedLocationData()
    }
}

public struct LocationData : Codable {
    var consent: String? = Constants.LocationConsent.NONE.rawValue
    var postcode: String?
    var state: String?
    
    var postal_code: String?
    var country_code: String?
    var admin_area: String?
    var sub_admin_area: String?
    var locality: String?
    var sub_locality: String?
}

public enum LocationState: String {
    case UNCHECKED
    case CHECKING
    case CHECKED
    case FAILED
    case UNAVAILABLE
    case DISABLED
}
