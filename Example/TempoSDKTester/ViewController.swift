import TempoSDK
import UIKit
import CoreLocation

class ViewController: UIViewController, TempoAdListener {

    var colouredBG: UIView?
    let locationManager = CLLocationManager()
    
    var adControllerReady: Bool = false
    var adController: TempoAdController? = nil
    
    @IBOutlet weak var loadAdButton: UIButton!
    @IBOutlet weak var showAdButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var checkLocationConsentButton: UIButton!
    @IBOutlet weak var requestLocationConsentButton: UIButton!
    
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        campaignId = textField.text
    }
    @IBAction func segmentedControlAction(_ sender: Any) {
        if (segmentedControl.selectedSegmentIndex == 0) {
            isInterstitial = true
        } else if (segmentedControl.selectedSegmentIndex == 1) {
            isInterstitial = false
        }
    }
    @IBAction func loadAd(_ sender: Any) {
        let startTime = Date().timeIntervalSince1970 * 1000
        print("Loading Ad now: \(Date().timeIntervalSince1970 * 1000)")
        print("Time taken: \(Date().timeIntervalSince1970 * 1000 - startTime)")
        
        closeKeyboard()
        loadAdButton.setTitle("Loading..." , for: .normal)
        loadAdButton.isEnabled = false
        if (campaignId == "") {
            if(adController == nil)  {
                print("👆 Creating a new 'self.adController'")
                self.adController = TempoAdController(tempoAdListener: self, appId: getAppId())
            }
            
            self.adController!.checkLocationConsentAndLoad(isInterstitial: isInterstitial, cpmFloor: 25.0, placementId: "XCODE_1")
            //adController?.loadAd(isInterstitial: isInterstitial, cpmFloor: 25.0, placementId: "XCODE")
            
        } else {
            adController?.loadSpecificAd(isInterstitial: isInterstitial, campaignId: campaignId)
        }
    }
    @IBAction func showAd(_ sender: Any) {
        print("Showing Ad now")
        closeKeyboard()
        adController?.showAd(parentViewController: self)
    }
    
    @IBAction func checkLocConsent(_ sender: Any) {
        print("🤷‍♂️ updateColor / requestLocationDirectly")
        TempoUtils.requestLocationDirectly(listener: self)
        updateColor()
    }
    @IBAction func requestLocConsent(_ sender: Any) {
        //TempoUtils.requestLocation()
        print("🤷‍♂️ requestWhenInUseAuthorization (button)")
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getRandomFloat() -> CGFloat {
        return CGFloat(Double.random(in: 0.6...1))
    }
    
    func updateColor() {
        self.view.backgroundColor = UIColor(red: getRandomFloat(), green: getRandomFloat(), blue: getRandomFloat(), alpha: 1)
    }
    
    var campaignId: String! = ""
    var isInterstitial: Bool! = true
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .fullScreen
        
//        print("🤷‍♂️ viewDidLoad (delegate assigned)")
//        locationManager.delegate = self
        
        // Inititalise Tempo SDK
        TempoDataBackup.checkHeldMetrics(completion: Metrics.pushMetrics)
        initializeUIButtons();
        
    }
    
    func initializeUIButtons(){
        showAdButton.backgroundColor = UIColor(red: 0.9, green: 0.9, blue:0.9, alpha: 1.0)
        showAdButton.layer.cornerRadius = 5
        loadAdButton.backgroundColor = UIColor(red: 0.9, green: 0.9, blue:0.9, alpha: 1.0)
        loadAdButton.layer.cornerRadius = 5
        showAdButton.isEnabled = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        closeKeyboard()
    }
    
    func closeKeyboard() {
        self.view.endEditing(true)
    }
    
    
    // Define a function that takes your loadAd function as an argument
    public func loadAdWithCustomLogic(adLoader: (Bool, Float?, String?) -> Void) {
        // You can perform some custom logic here before loading the ad
        let isInterstitial = isInterstitial ?? false
        let cpmFloor: Float? = 25.0
        let placementId = "XCODE"
        
        // Call the provided adLoader function
        adLoader(isInterstitial, cpmFloor, placementId)
        
        // You can also do additional work after loading the ad, if needed
        print("Custom logic after loading ad")
    }
    
    func loadInterstitialAds() {
        adController?.loadAd(isInterstitial: isInterstitial, cpmFloor: 25.0, placementId: "XCODE")
    }
    
    
    
    func setInterstitialReady(_ ready:Bool){
        adControllerReady = ready
        loadAdButton.setTitle("Load Ad", for: .normal)
        loadAdButton.isEnabled = true
        showAdButton.isEnabled = true
    }
    
    func onTempoAdFetchSucceeded(isInterstitial: Bool) {
        print("\(TempoUtils.getAdTypeString(isInterstitial: isInterstitial)) :: ready")
        setInterstitialReady(true)
    }
    
    func onTempoAdFetchFailed(isInterstitial: Bool, reason: String?) {
        print("\(TempoUtils.getAdTypeString(isInterstitial: isInterstitial)) :: load failed \(reason ?? "uknown")")
        setInterstitialReady(true)
        showAdButton.isEnabled = false
    }
    
    func onTempoAdClosed(isInterstitial: Bool) {
        print("\(TempoUtils.getAdTypeString(isInterstitial: isInterstitial)) :: close")
        setInterstitialReady(true)
        
        showAdButton.isEnabled = false
        self.adController = nil
        print("👇 Destroying 'self.adController'")
    }
    
    func onTempoAdDisplayed(isInterstitial: Bool) {
        print("\(TempoUtils.getAdTypeString(isInterstitial: isInterstitial)) :: displayed")
        showAdButton.isEnabled = false
    }

    func onTempoAdClicked(isInterstitial: Bool) {
        print("\(TempoUtils.getAdTypeString(isInterstitial: isInterstitial)) :: clicked")
    }
    
    func getTempoAdapterVersion() -> String? {
        print("\(TempoUtils.getAdTypeString(isInterstitial: isInterstitial)) :: version requested")
        return DemoConstants.ADAP_VERSION
    }
    
    func getTempoAdapterType() -> String? {
        print("\(TempoUtils.getAdTypeString(isInterstitial: isInterstitial)) :: adapter type requested")
        return nil;
    }
    
    func onTempoAdShowFailed(isInterstitial: Bool, reason: String?) {
        print("\(TempoUtils.getAdTypeString(isInterstitial: isInterstitial)) :: show failed: \(reason ?? "uknown")")
    }
    
    func hasUserConsent() -> Bool? {
        print("\(TempoUtils.getAdTypeString(isInterstitial: isInterstitial)) :: user consent requested")
        return true;
    }
    
    func getAppId() -> String {
        return TempoSDK.Constants.isProd ? "8" : "5";
    }
    
    
    /// -----
    func parseLocationJson(jsonString: String?) {
        print(jsonString ?? "?????")
    }
    
   
    
    // Request location permission and start updating location
    func requestAuthorisation() {
        print("🤷‍♂️ requestAuthorisation")
        locationManager.requestWhenInUseAuthorization()
    }
    
    // Stop updating location
    func stopUpdatingLocation() {
        print("🤷‍♂️ stopUpdatingLocation")
        locationManager.stopUpdatingLocation()
    }
    
    func isLocationAccessEnabled() {
       if CLLocationManager.locationServicesEnabled() {
          switch CLLocationManager.authorizationStatus() {
          case .notDetermined:
                print("No access - notDetermined")
          case .restricted:
             print("No access - restricted")
          case .denied:
             print("No access - denied")
             case .authorizedAlways:
                print("Access - always ")
          case  .authorizedWhenInUse:
              print("Access - authorizedWhenInUse ")
          }
       } else {
          print("Location services not enabled")
       }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("🤷‍♂️ didChangeAuthorization: \(status)")
        if status == .authorizedWhenInUse {
            print("🤷‍♂️ startUpdatingLocation: \(status)")
            //locationManager.startUpdatingLocation()
            //locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("🤷‍♂️ didUpdateLocations: [\(locations.count)] \(manager.description)")
        if let location = locations.last {
                    // Stop updating location when you have the desired location
                    stopUpdatingLocation()
                    
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
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            TempoUtils.Say(msg: "👉👉👉 didFailWithError: \(error)")
            locationManager.stopUpdatingLocation()
    
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
