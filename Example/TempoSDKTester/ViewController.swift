import TempoSDK
import UIKit

class ViewController: UIViewController, TempoAdListener {

    var interstitialReady: Bool = false
    var interstitial: TempoAdController? = nil
    
    @IBOutlet weak var loadAdButton: UIButton!
    @IBOutlet weak var showAdButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

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
        print("Loading Ad now")
        closeKeyboard()
        loadAdButton.setTitle("Loading..." , for: .normal)
        loadAdButton.isEnabled = false
        if (campaignId == "") {
            if(interstitial == nil)
            {
                self.interstitial = TempoAdController(tempoAdListener: self, appId: getAppId())
            }
            interstitial?.loadAd(isInterstitial: isInterstitial, cpmFloor: 25.0, placementId: "XCODE")
        } else {
            interstitial?.loadSpecificAd(isInterstitial: isInterstitial, campaignId: campaignId)
        }
    }

    @IBAction func showAd(_ sender: Any) {
        print("Showing Ad now")
        closeKeyboard()
        interstitial?.showAd(parentViewController: self)
    }
    
    
    func setInterstitialReady(_ ready:Bool){
        interstitialReady = ready
        loadAdButton.setTitle("Load Ad", for: .normal)
        loadAdButton.isEnabled = true
        showAdButton.isEnabled = true
    }
    
    func onTempoAdFetchSucceeded(isInterstitial: Bool) {
        print("\(TempoUtils.getAdTypeString(isInterstitial: isInterstitial)) :: ready")
        setInterstitialReady(true)
    }
    
    func onTempoAdFetchFailed(isInterstitial: Bool) {
        print("\(TempoUtils.getAdTypeString(isInterstitial: isInterstitial)) :: failed")
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
    
    func hasUserConsent() -> Bool? {
        print("\(TempoUtils.getAdTypeString(isInterstitial: isInterstitial)) :: user consent requested")
        return true;
    }
    
    func getAppId() -> String {
        return TempoSDK.Constants.isProd ? "8" : "5";
    }
    
}

