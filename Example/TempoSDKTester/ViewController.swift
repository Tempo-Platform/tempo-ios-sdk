import TempoSDK
import UIKit

class ViewController: UIViewController, TempoInterstitialListener {

    
    
    public static let TEST_APP_ID: String = "1"; // 1 for DEV, 8 for PROD

    var interstitialReady:Bool = false
    var interstitial:TempoInterstitial? = nil
    
    
    @IBOutlet weak var loadAdButton: UIButton!
    @IBOutlet weak var showAdButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    private var campaignId: String! = ""
    private var isInterstitial: Bool! = true
    
    private var demoAdaptervVersion = "1.0.0"
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
//        view.backgroundColor = .gray
        super.viewDidLoad()
        self.modalPresentationStyle = .fullScreen
        self.interstitial = TempoInterstitial(parentViewController:self, delegate:self, appId: ViewController.TEST_APP_ID)
        initializeUIButtons();
        
//        // For testing metric time functions
//        var deviceTime: Bool = false
//        TempoUtcRetriever.getUTCTime(&deviceTime)
//        print("API time? \(!deviceTime)")
    }
    
    private func initializeUIButtons(){
        showAdButton.backgroundColor = UIColor(red: 0.9, green: 0.9, blue:0.9, alpha: 1.0)
        showAdButton.layer.cornerRadius = 5
        loadAdButton.backgroundColor = UIColor(red: 0.9, green: 0.9, blue:0.9, alpha: 1.0)
        loadAdButton.layer.cornerRadius = 5
        showAdButton.isEnabled = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        closeKeyboard()
    }
    
    private func closeKeyboard() {
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
    
    func getType(isInterstitial: Bool) -> String
    {
        return isInterstitial ? "INTERSTITIAL" : "REWARDED"
    }
}

