import Foundation
import CoreLocation

public class TempoProfile: NSObject, CLLocationManagerDelegate { //TODO: Make class internal/private/default(none)?
    var locManager = CLLocationManager()
    var location: CLLocation?
    
    override init() {
        super.init()
        if #available(iOS 14.0, *) {
            TempoUtils.Say(msg: "🥶🥶🥶 TempoProfile.init()")
            locManager.delegate = self
            //requestLocationConsent()
            //            locManager.requestWhenInUseAuthorization()
            //            locManager.requestLocation()
            //locManager.desiredAccuracy = kCLLocationAccuracyBest
            locManager.requestWhenInUseAuthorization()
            locManager.requestLocation()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        TempoUtils.Say(msg: "👉👉👉 didUpdateLocations: \(locations.count)")
        //        if locations.first != nil {
        //            locManager.stopUpdatingLocation()
        //        }
        //
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
    
    /// Public function for prompting consent (used for testing)
    public func requestLocationConsent() {

        TempoUtils.Say(msg: "🙏🙏🙏 requestLocationConsent")
        locManager.requestWhenInUseAuthorization()
        locManager.requestLocation()
    }

    /// Get CLAuthorizationStatus location consent value
    private func getLocationAuthorisationStatus() -> CLAuthorizationStatus {
        var locationAuthorizationStatus : CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            locationAuthorizationStatus =  locManager.authorizationStatus
        } else {
            // Fallback for earlier versions
            locationAuthorizationStatus = CLLocationManager.authorizationStatus()
        }
        return locationAuthorizationStatus
    }

    /// Main public function for running a consent check - escaping completion function for running loadAds when value found
    public func checkLocationServicesConsent (
        completion: @escaping (LocationData, Bool, Float?, String?) -> Void,
        isInterstitial: Bool,
        cpmFloor: Float?,
        placementId: String?) {

            var ld = LocationData()
            // CLLocationManager.authorizationStatus can cause UI unresponsiveness if invoked on the main thread.
            DispatchQueue.global().async {

                // Make sure location servics are available
                if CLLocationManager.locationServicesEnabled() {

                    // get authorisation status
                    let authStatus = self.getLocationAuthorisationStatus()

                    switch (authStatus) {
                    case .authorizedAlways, .authorizedWhenInUse:
                        print("Access - always or authorizedWhenInUse")
                        if #available(iOS 14.0, *) {
                            // iOS 14 intro precise/general options
                            if self.locManager.accuracyAuthorization == .reducedAccuracy {
                                ld.location_consent = Constants.LocationConsent.GENERAL.rawValue
                                //self.myRequestLocation(consentType: Constants.LocationConsent.GENERAL)
                                completion(ld, isInterstitial, cpmFloor, placementId)
                                return
                            } else {
                                ld.location_consent = Constants.LocationConsent.PRECISE.rawValue
                                //self.myRequestLocation(consentType: Constants.LocationConsent.PRECISE)
                                completion(ld, isInterstitial, cpmFloor, placementId)
                                return
                            }
                        } else {
                            // Pre-iOS 14 considered precise
                            completion(ld, isInterstitial, cpmFloor, placementId)
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

                // If we reach here = Constants.LocationConsent.None
                var ld = LocationData()
                ld.location_consent = Constants.LocationConsent.NONE.rawValue
                completion(ld, isInterstitial, cpmFloor, placementId)
            }
        }

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
    var location_consent: String?
    var postcode: String?
    var state: String?
}
