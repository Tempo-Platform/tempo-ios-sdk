import TempoSDK
import UIKit

class ViewController: UIViewController, TempoAdListener {

    var interstitialReady:Bool = false
    var interstitial:TempoAdController? = nil
    
    @IBOutlet weak var loadAdButton: UIButton!
    @IBOutlet weak var showAdButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    var campaignId: String! = ""
    var isInterstitial: Bool! = true
    var demoAdaptervVersion = DemoConstants.ADAP_VERSION
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .fullScreen
        self.interstitial = TempoAdController(parentViewController: self, delegate: self, appId: getAppId())
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
        loadAdButton.setTitle("Loading..", for: .normal)
        loadAdButton.isEnabled = false
        if (campaignId == "") {
            interstitial?.loadAd(isInterstitial: isInterstitial, cpmFloor: 25.0, placementId: "XCODE")
        } else {
            interstitial?.loadSpecificAd(isInterstitial: isInterstitial, campaignId: campaignId)
        }
    }

    @IBAction func showAd(_ sender: Any) {
        print("Showing Ad now")
        closeKeyboard()
        interstitial?.showAd()
    }
    
    
    func setInterstitialReady(_ ready:Bool){
        interstitialReady = ready
        loadAdButton.setTitle("Load Ad", for: .normal)
        loadAdButton.isEnabled = true
        showAdButton.isEnabled = true
    }
    
    func onAdFetchSucceeded(isInterstitial: Bool) {
        print("\(getType(isInterstitial: isInterstitial)) :: ready")
        setInterstitialReady(true)
    }
    
    func onAdFetchFailed(isInterstitial: Bool) {
        print("\(getType(isInterstitial: isInterstitial)) :: failed")
    }
    
    func onAdClosed(isInterstitial: Bool) {
        print("\(getType(isInterstitial: isInterstitial)) :: close")
    }
    
    func onAdDisplayed(isInterstitial: Bool) {
        print("\(getType(isInterstitial: isInterstitial)) :: displayed")
        showAdButton.isEnabled = false
    }

    func onAdClicked(isInterstitial: Bool) {
        print("\(getType(isInterstitial: isInterstitial)) :: clicked")
    }
    
    func onVersionExchange(sdkVersion: String) -> String? {
        print("\(getType(isInterstitial: isInterstitial)) :: version swap requested")
        return demoAdaptervVersion
    }
    
    func onGetAdapterType() -> String? {
        print("\(getType(isInterstitial: isInterstitial)) :: adapter type requested")
        return nil;
    }
    
    func hasUserConsent() -> Bool? {
        print("\(getType(isInterstitial: isInterstitial)) :: user consent requested")
        return true;
    }
    
    
    func getType(isInterstitial: Bool) -> String {
        return isInterstitial ? "INTERSTITIAL" : "REWARDED"
    }
    
    func getAppId() -> String {
        return TempoSDK.Constants.IS_PROD ? "8" : "5";
    }
    
}

