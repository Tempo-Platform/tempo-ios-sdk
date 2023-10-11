import Foundation
import CoreLocation

public class TempoProfile: NSObject, CLLocationManagerDelegate { //TODO: Make class internal/private/default(none)?
    
    // This instance's location manager delegate
    let locManager = CLLocationManager()
    let requestOnLoad_testing = false
    
    // The static that can be retrieved at any time during the SDK's usage
    static var locData: LocationData?
    
    override init() {
        super.init()
        if #available(iOS 14.0, *) {
            
            // Create a new locData object for the static reference if first initialisation
            if(TempoProfile.locData == nil) {
                TempoProfile.locData = LocationData()
            }
            
            // Assign manager delegate
            locManager.delegate = self
            
            // For testing, loads when initialised
            if(requestOnLoad_testing) {
                locManager.requestWhenInUseAuthorization()
                locManager.startUpdatingLocation()
                locManager.requestLocation()
            }
        }
    }
    
    /// Main public function for running a consent check - escaping completion function for running loadAds when value found
    public func checkLocConsent (
        completion: @escaping (Bool, Float?, String?) -> Void,
        isInterstitial: Bool,
        cpmFloor: Float?,
        placementId: String?) {

            // CLLocationManager.authorizationStatus can cause UI unresponsiveness if invoked on the main thread.
            DispatchQueue.global().async {

                // Make sure location servics are available
                if CLLocationManager.locationServicesEnabled() {

                    // get authorisation status
                    let authStatus = self.getLocAuthStatus()

                    switch (authStatus) {
                    case .authorizedAlways, .authorizedWhenInUse:
                        print("Access - always or authorizedWhenInUse")
                        if #available(iOS 14.0, *) {
                            
                            // iOS 14 intro precise/general options
                            if self.locManager.accuracyAuthorization == .reducedAccuracy {
                                // Update LocationData singleton as GENERAL
                                TempoProfile.locData?.lc = Constants.LocationConsent.GENERAL.rawValue
                                completion(isInterstitial, cpmFloor, placementId)
                                return
                            } else {
                                    // Update LocationData singleton as PRECISE
                                TempoProfile.locData?.lc = Constants.LocationConsent.PRECISE.rawValue
                                completion(isInterstitial, cpmFloor, placementId)
                                return
                            }
                        } else {
                            // Update LocationData singleton as PRECISE (pre-iOS 14 considered precise)
                            TempoProfile.locData?.lc = Constants.LocationConsent.PRECISE.rawValue
                            completion(isInterstitial, cpmFloor, placementId)
                            return
                        }
                    case .restricted, .denied:
                        print("No access - restricted or denied")
                    case .notDetermined:
                        print("No access - notDetermined")
                    @unknown default:
                        print("Unknown authorization status")
                    }
                } else {
                    print("Location services not enabled")
                }
                
                // Update LocationData singleton as GENERAL
                TempoProfile.locData?.lc = Constants.LocationConsent.NONE.rawValue
                completion(isInterstitial, cpmFloor, placementId)
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
    
    /// Public function for prompting consent (used for testing)
    public func requestLocationConsentNowAsTesting() {
        TempoUtils.Say(msg: "🪲🪲🪲 requestLocationConsent")
        locManager.requestWhenInUseAuthorization()
        locManager.requestLocation()
    }

    /// Location Manager callback: didChangeAuthorization
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        TempoUtils.Say(msg: "👉👉👉 didChangeAuthorization: \((status as CLAuthorizationStatus).rawValue)")
        if status == .authorizedWhenInUse {
            TempoUtils.Say(msg: "🤷‍♂️🤷‍♂️🤷‍♂️ status == .authorizedWhenInUse (do something?)")
            // do stuff
            TempoUtils.Say(msg: "🤷‍♂️🤷‍♂️🤷‍♂️ status Part II \(CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self))|\(CLLocationManager.isRangingAvailable())")
            locManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            //locManager.startUpdatingLocation()
            locManager.requestLocation()
//            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) { // TODO: Could these help?
//                if CLLocationManager.isRangingAvailable() {
//                    // do stuff
//                    TempoUtils.Say(msg: "🤷‍♂️🤷‍♂️🤷‍♂️ status Part II")
//                    locManager.startUpdatingLocation()
//                }
//            }
        }
    }

    /// Location Manager callback: didUpdateLocations
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        TempoUtils.Say(msg: "👉👉👉 didUpdateLocations: \(locations.count)")
        
//        if locations.first != nil {
//            locManager.stopUpdatingLocation() // TODO: Needed if I'm doing spot checks?
//        }
        
        if let location = locations.last {
            
            // Reverse geocoding to get the state
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let error = error {
                    print("Reverse geocoding failed with error: \(error.localizedDescription)")
                    return
                }
                
                if let placemark = placemarks?.first {
                    if let state = placemark.name {
                        print("name: \t\t\t\t\t\(state)")
                    }
                    else {
                        print("name: \t\t\t\t\t[UNAVAILABLE]")
                    }
                    
                    if let state = placemark.thoroughfare {
                        print("thoroughfare: \t\t\t\(state)")
                    }
                    else {
                        print("thoroughfare: \t\t\t[UNAVAILABLE]")
                    }
                    
                    if let state = placemark.subThoroughfare {
                        print("subThoroughfare: \t\t\(state)")
                    }
                    else {
                        print("subThoroughfare: [UNAVAILABLE]")
                    }
                    
                    
                    if let state = placemark.locality {
                        print("locality: \t\t\t\t\(state)")
                    }
                    else {
                        print("locality: \t\t\t\t[UNAVAILABLE]")
                    }
                    
                    
                    if let state = placemark.subLocality {
                        print("subLocality: \t\t\t\(state)")
                    }
                    else {
                        print("subLocality: \t\t\t[UNAVAILABLE]")
                    }
                    
                    
                    if let state = placemark.administrativeArea {
                        print("administrativeArea: \t\(state) <---------------- STATE")
                        TempoProfile.locData?.state = placemark.administrativeArea
                    }
                    else {
                        print("administrativeArea: \t[UNAVAILABLE]")
                    }
                    
                    
                    if let state = placemark.subAdministrativeArea {
                        print("subAdministrativeArea: \t\(state)")
                    }
                    else {
                        print("subAdministrativeArea: \t[UNAVAILABLE]")
                    }
                    
                    
                    if let state = placemark.postalCode {
                        print("postalCode: \t\t\t\(state)")
                        TempoProfile.locData?.postcode = placemark.postalCode
                    }
                    else {
                        print("postalCode: \t\t\t[UNAVAILABLE]")
                    }
                    
                    
                    if let state = placemark.isoCountryCode {
                        print("isoCountryCode: \t\t\(state)")
                    }
                    else {
                        print("isoCountryCode: \t\t[UNAVAILABLE]")
                    }
                    
                    
                    if let state = placemark.country {
                        print("country: \t\t\t\t\(state)")
                    }
                    else {
                        print("country: \t\t\t\t[UNAVAILABLE]")
                    }
                    
                    
                    if let state = placemark.inlandWater {
                        print("inlandWater: \t\t\t\(state)")
                    }
                    else {
                        print("inlandWater: \t\t\t[UNAVAILABLE]")
                    }
                    
                    
                    if let state = placemark.ocean {
                        print("ocean: \t\t\t\t\t\(state)")
                    }
                    else {
                        print("ocean: \t\t\t\t\t[UNAVAILABLE]")
                    }
                    
                    
                    if let state = placemark.areasOfInterest {
                        print("areasOfInterest: \t\t\(state)")
                    }
                    else {
                        print("areasOfInterest: \t\t[UNAVAILABLE]")
                    }
                }
                
                
            }
        }
    }
   
    /// Location Manager callback: didFailWithError
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            TempoUtils.Say(msg: "👉👉👉 didFailWithError: \(error)")
            locManager.stopUpdatingLocation()
    
                    if let clErr = error as? CLError {
                        switch clErr.code {
                        case .locationUnknown, .denied, .network:
                            print("Location request failed with error: \(clErr.localizedDescription)")
                        case .headingFailure:
                            print("Heading request failed with error: \(clErr.localizedDescription)")
                        case .rangingUnavailable, .rangingFailure:
                            print("Ranging request failed with error: \(clErr.localizedDescription)")
                        case .regionMonitoringDenied, .regionMonitoringFailure, .regionMonitoringSetupDelayed, .regionMonitoringResponseDelayed:
                            print("Region monitoring request failed with error: \(clErr.localizedDescription)")
                        default:
                            print("Unknown location manager error: \(clErr.localizedDescription)")
                        }
                    } else {
                        print("Unknown error occurred while handling location manager error: \(error.localizedDescription)")
                    }
        }
}
    
//extension TempoProfile: CLLocationManagerDelegate {
    
//    /// Public function for prompting consent (used for testing)
//    public func requestLocationConsent() {
//        
//        TempoUtils.Say(msg: "🙏🙏🙏 requestLocationConsent")
//        locManager.requestWhenInUseAuthorization()
//        locManager.requestLocation()
//    }
//    
//    /// Get CLAuthorizationStatus location consent value
//    private func getLocationAuthorisationStatus() -> CLAuthorizationStatus {
//        var locationAuthorizationStatus : CLAuthorizationStatus
//        if #available(iOS 14.0, *) {
//            locationAuthorizationStatus =  locManager.authorizationStatus
//        } else {
//            // Fallback for earlier versions
//            locationAuthorizationStatus = CLLocationManager.authorizationStatus()
//        }
//        return locationAuthorizationStatus
//    }
//    
//    /// Main public function for running a consent check - escaping completion function for running loadAds when value found
//    public func checkLocationServicesConsent (
//        completion: @escaping (LocationData, Bool, Float?, String?) -> Void,
//        isInterstitial: Bool,
//        cpmFloor: Float?,
//        placementId: String?) {
//            
//            var ld = LocationData()
//            // CLLocationManager.authorizationStatus can cause UI unresponsiveness if invoked on the main thread.
//            DispatchQueue.global().async {
//                
//                // Make sure location servics are available
//                if CLLocationManager.locationServicesEnabled() {
//                    
//                    // get authorisation status
//                    let authStatus = self.getLocationAuthorisationStatus()
//                    
//                    switch (authStatus) {
//                    case .authorizedAlways, .authorizedWhenInUse:
//                        print("Access - always or authorizedWhenInUse")
//                        if #available(iOS 14.0, *) {
//                            // iOS 14 intro precise/general options
//                            if self.locManager.accuracyAuthorization == .reducedAccuracy {
//                                ld.location_consent = Constants.LocationConsent.GENERAL.rawValue
//                                //self.myRequestLocation(consentType: Constants.LocationConsent.GENERAL)
//                                completion(ld, isInterstitial, cpmFloor, placementId)
//                                return
//                            } else {
//                                ld.location_consent = Constants.LocationConsent.PRECISE.rawValue
//                                //self.myRequestLocation(consentType: Constants.LocationConsent.PRECISE)
//                                completion(ld, isInterstitial, cpmFloor, placementId)
//                                return
//                            }
//                        } else {
//                            // Pre-iOS 14 considered precise
//                            completion(ld, isInterstitial, cpmFloor, placementId)
//                            return
//                        }
//                    case .restricted, .denied:
//                        print("No access - restricted or denied")
//                    case .notDetermined:
//                        print("No access - notDetermined")
//                    @unknown default:
//                        print("Unknown authorization status")
//                    }
//                } else {
//                    print("Location services not enabled")
//                }
//                
//                // If we reach here = Constants.LocationConsent.None
//                var ld = LocationData()
//                ld.location_consent = Constants.LocationConsent.NONE.rawValue
//                completion(ld, isInterstitial, cpmFloor, placementId)
//            }
//        }
//    
//    
//    
//    
//    
//    // ---------- NEW ----------
//
//    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        TempoUtils.Say(msg: "👉👉👉 didChangeAuthorization: \((status as CLAuthorizationStatus).rawValue)")
//        if status == .authorizedAlways {
//            TempoUtils.Say(msg: "🤷‍♂️🤷‍♂️🤷‍♂️ status == .authorizedWhenInUse (do something?)")
//            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
//                if CLLocationManager.isRangingAvailable() {
//                    // do stuff
//                    TempoUtils.Say(msg: "🤷‍♂️🤷‍♂️🤷‍♂️ status Part II")
//                }
//            }
//        }
//    }
//    
//    
//    // CoreLocation callbacks for when Authorisation status has updater
//    
//    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        TempoUtils.Say(msg: "👉👉👉 didUpdateLocations: \(locations.count)")
//        if locations.first != nil {
//            locManager.stopUpdatingLocation()
//        }
//    }
//    
//    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
//        TempoUtils.Say(msg: "👉👉👉 didUpdateHeading: \(newHeading)")
//    }
//    
//
//}


public struct LocationData : Codable {
    var lc: String?
    var postcode: String?
    var state: String?
}
