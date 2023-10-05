import TempoSDK
import UIKit

class ViewController: UIViewController, TempoAdListener {

    


    var adControllerReady: Bool = false
    var adController: TempoAdController? = nil
    
    @IBOutlet weak var loadAdButton: UIButton!
    @IBOutlet weak var showAdButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var checkLocationConsentButton: UIButton!
    @IBOutlet weak var requestLocationConsentButton: UIButton!
    
    var campaignId: String! = ""
    var isInterstitial: Bool! = true
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .fullScreen
        
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
                self.adController = TempoAdController(tempoAdListener: self, appId: getAppId())
            }
            
            self.adController!.checkLocationConsentAndLoad(isInterstitial: isInterstitial, cpmFloor: 25.0, placementId: "XCODE")
            //adController?.loadAd(isInterstitial: isInterstitial, cpmFloor: 25.0, placementId: "XCODE")
            
        } else {
            adController?.loadSpecificAd(isInterstitial: isInterstitial, campaignId: campaignId)
        }
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
    

    @IBAction func showAd(_ sender: Any) {
        print("Showing Ad now")
        closeKeyboard()
        adController?.showAd(parentViewController: self)
    }
    
    
    @IBAction func checkLocConsent(_ sender: Any) {
        //TempoUtils.hasLocationServicesConsent()
    }
    
    @IBAction func requestLocConsent(_ sender: Any) {
        TempoUtils.requestLocation()
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
    
    func onTempoAdFetchFailed(isInterstitial: Bool) {
        print("\(TempoUtils.getAdTypeString(isInterstitial: isInterstitial)) :: load failed")
        setInterstitialReady(true)
        showAdButton.isEnabled = false
    }
    
    func onTempoAdClosed(isInterstitial: Bool) {
        print("\(TempoUtils.getAdTypeString(isInterstitial: isInterstitial)) :: close")
        setInterstitialReady(true)
        showAdButton.isEnabled = false
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
    
    func onTempoAdShowFailed(isInterstitial: Bool, adNotReady: Bool) {
        print("\(TempoUtils.getAdTypeString(isInterstitial: isInterstitial)) :: show failed: \(adNotReady)")
    }
    
    func hasUserConsent() -> Bool? {
        print("\(TempoUtils.getAdTypeString(isInterstitial: isInterstitial)) :: user consent requested")
        return true;
    }
    
    func getAppId() -> String {
        return TempoSDK.Constants.isProd ? "8" : "5";
    }
    
}

