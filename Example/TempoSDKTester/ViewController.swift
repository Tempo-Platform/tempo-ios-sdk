import TempoSDK
import UIKit

class ViewController: UIViewController, TempoInterstitialListener {

    var interstitialReady:Bool = false
    var interstitial:TempoInterstitial? = nil

    @IBOutlet weak var loadAdButton: UIButton!
    @IBOutlet weak var showAdButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.interstitial = TempoInterstitial(parentViewController:self, delegate:self)
        initializeUIButtons();
    }
    
    private func initializeUIButtons(){
        showAdButton.backgroundColor = UIColor(red: 0.9, green: 0.9, blue:0.9, alpha: 1.0)
        showAdButton.layer.cornerRadius = 5
        loadAdButton.backgroundColor = UIColor(red: 0.9, green: 0.9, blue:0.9, alpha: 1.0)
        loadAdButton.layer.cornerRadius = 5
        showAdButton.isEnabled = false
    }
    
    @IBAction func loadAd(_ sender: Any) {
        print("Loading Ad now")
        interstitial?.loadAd()
    }

    @IBAction func showAd(_ sender: Any) {
        print("Showing Ad now")
        interstitial?.showAd()
    }
    
    
    func setInterstitialReady(_ ready:Bool){
        interstitialReady = ready
        showAdButton.isEnabled = true
    }
    
    func onAdFetchSucceeded() {
        print("Interstitial :: ready")
        setInterstitialReady(true)
    }
    
    func onAdFetchFailed() {
        print("Interstitial :: failed")
    }
    
    func onAdClosed() {
        print("Interstitial :: close")
    }
    
    func onAdDisplayed() {
        print("Interstitial :: displayed")
        showAdButton.isEnabled = false
    }
}

