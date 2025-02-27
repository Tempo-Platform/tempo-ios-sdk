import TempoSDK
import UIKit
import CoreLocation

class ViewController: UIViewController, TempoAdListener {
    
    var locationManager: CLLocationManager?
    var adControllerReady: Bool = false
    var adController: TempoAdController? = nil
    var colouredBG: UIView?
    var campaignId: String! = ""
    var isInterstitial: Bool! = true
    
    // Button references
    @IBOutlet weak var loadAdButton: UIButton!
    @IBOutlet weak var showAdButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // Buttons actions
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
        closeKeyboard()
        loadAdButton.setTitle("Loading..." , for: .normal)
        loadAdButton.isEnabled = false
        if (campaignId == "") {
            if(adController == nil)  {
                self.adController = TempoAdController(tempoAdListener: self, appId: getAppId())
            }
            
            self.adController!.loadAd(isInterstitial: isInterstitial, cpmFloor: 25.0, placementId: "XCODE")
            
        } else {
            adController?.loadSpecificAd(isInterstitial: isInterstitial, campaignId: campaignId)
        }
    }
    @IBAction func showAd(_ sender: Any) {
        closeKeyboard()
        adController?.showAd(parentViewController: self)
    }
    @IBAction func leftButtonAction(_ sender: Any) {
            print("🤷‍♂️ updateColor / requestLocationDirectly")
            //TempoUtils.requestLocationDirectly(listener: self)
            updateColor()
    }
    @IBAction func rightButtonAction(_ sender: Any) {
        print("🔘👈🏻 requestWhenInUseAuthorization (button)")
        locationManager = CLLocationManager()
        locationManager!.requestWhenInUseAuthorization()
    }
    
    /// Override initialiser
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .fullScreen
        
        // Inititalise Tempo SDK
        do{
            try TempoDataBackup.checkHeldMetrics(completion: Metrics.pushMetrics)
        } catch {
            TempoUtils.warn(msg: "Error checking backups: \(error)")
        }
        
        initializeUIButtons();
    }
    
    /// Sets up main page  test IU
    func initializeUIButtons(){
        
        // Show button
        showAdButton.backgroundColor = UIColor(red: 0.9, green: 0.9, blue:0.9, alpha: 1.0)
        showAdButton.layer.cornerRadius = 5
        showAdButton.isEnabled = false
        
        // Load button
        loadAdButton.backgroundColor = UIColor(red: 0.9, green: 0.9, blue:0.9, alpha: 1.0)
        loadAdButton.layer.cornerRadius = 5
    }

    /// Manually start ad fetching by which the rest of the ad process flows
    func loadInterstitialAds() {
        adController?.loadAd(isInterstitial: isInterstitial, cpmFloor: 25.0, placementId: "XCODE")
    }
    
    // Updates loading UI to indicate ad ready or not
    func setAdControllerReady(_ ready:Bool){
        adControllerReady = ready
        loadAdButton.setTitle("Load Ad", for: .normal)
        loadAdButton.isEnabled = true
        showAdButton.isEnabled = true
    }
    
    /* ---------------- TEMPO LISTENER CALLBACKS  ---------------- */
    func onTempoAdFetchSucceeded(isInterstitial: Bool) {
        print("\(TempoUtils.getAdTypeString(isInterstitial: isInterstitial)) :: ready")
        setAdControllerReady(true)
    }
    func onTempoAdFetchFailed(isInterstitial: Bool, reason: String?) {
        print("\(TempoUtils.getAdTypeString(isInterstitial: isInterstitial)) :: load failed \(reason ?? "uknown")")
        setAdControllerReady(true)
        showAdButton.isEnabled = false
    }
    func onTempoAdClosed(isInterstitial: Bool) {
        print("\(TempoUtils.getAdTypeString(isInterstitial: isInterstitial)) :: close")
        setAdControllerReady(true)
        showAdButton.isEnabled = false
        self.adController = nil
    }
    func onTempoAdDisplayed(isInterstitial: Bool) {
        print("\(TempoUtils.getAdTypeString(isInterstitial: isInterstitial)) :: displayed")
        showAdButton.isEnabled = false
    }
    func onTempoAdShowFailed(isInterstitial: Bool, reason: String?) {
        print("\(TempoUtils.getAdTypeString(isInterstitial: isInterstitial)) :: show failed: \(reason ?? "uknown")")
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
    func hasUserConsent() -> Bool? {
        print("\(TempoUtils.getAdTypeString(isInterstitial: isInterstitial)) :: user consent requested")
        return true;
    }
    
//    // Request location permission and start updating location
//    func requestAuthorisation() {
//        print("🤷‍♂️ requestAuthorisation")
//        locationManager.requestWhenInUseAuthorization()
//    }
//    
//    // Stop updating location
//    func stopUpdatingLocation() {
//        print("🤷‍♂️ stopUpdatingLocation")
//        locationManager.stopUpdatingLocation()
//    }
//    
//    func isLocationAccessEnabled() {
//        if CLLocationManager.locationServicesEnabled() {
//            switch CLLocationManager.authorizationStatus() {
//            case .restricted:    print("No access - restricted")
//            case .denied:    print("No access - denied")
//            case .authorizedAlways:   print("Access - always ")
//            case  .authorizedWhenInUse:   print("Access - authorizedWhenInUse ")
//            case .notDetermined: fallthrough
//            @unknown default: print("No access - notDetermined")
//            }
//        } else {
//            print("Location services not enabled")
//        }
//    }
    
    
    /* ----------------- GENERAL SETUP ---------------- */
    /// Override status bar preference
    override var prefersStatusBarHidden: Bool {
        return true
    }
    /// Override touch behaviour
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        closeKeyboard()
    }
    /// Closes any visible keyboard (?)
    func closeKeyboard() {
        self.view.endEditing(true)
    }
    
    
    /* ----------------- TESTING ONLY ---------------- */
    /// Returns appropriate Ad ID based on dev/prod environment
    func getAppId() -> String {
        switch(Constants.environment){
        case Constants.Environment.STG:
            return DemoConstants.APP_ID_PROD
        case Constants.Environment.PRD:
            return DemoConstants.APP_ID_PROD
        case Constants.Environment.DEV:
            fallthrough
        default:
            return DemoConstants.APP_ID_DEV
        }
        //return TempoSDK.Constants.isProd ? DemoConstants.APP_ID_PROD : DemoConstants.APP_ID_DEV;
    }
    /// Returns a random CGFloat value between 0.5 and 1
    func getRandomFloat() -> CGFloat {
        return CGFloat(Double.random(in: 0.6...1))
    }
    /// Update background view  with random color (for testing UI functions still workingl not freezing)
    func updateColor() {
        self.view.backgroundColor = UIColor(red: getRandomFloat(), green: getRandomFloat(), blue: getRandomFloat(), alpha: 1)
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
    
}

extension ViewController: CLLocationManagerDelegate {
    
    func outputLocationProperty(labelName: String, property: String?) {
        // TODO: Work out the tabs by string length..?
        
        if let checkedValue = property {
            print("\(labelName): \(checkedValue)")
        }
        else {
            print("\(labelName): [UNAVAILABLE]")
        }
    }
    
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
                    //stopUpdatingLocation()
                    
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
            TempoUtils.say(msg: "👉👉👉 didFailWithError: \(error)")
            locationManager?.stopUpdatingLocation()
    
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
