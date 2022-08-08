import TempoSDK
import UIKit

class ViewController: UIViewController, TempoInterstitialListener {

    var interstitialReady:Bool = false
    var interstitial:TempoInterstitial? = nil
    
    
    @IBOutlet weak var loadAdButton: UIButton!
    @IBOutlet weak var showAdButton: UIButton!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
//        view.backgroundColor = .gray
        super.viewDidLoad()
        self.modalPresentationStyle = .fullScreen
        self.interstitial = TempoInterstitial(parentViewController:self, delegate:self, appId:"8")
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
        loadAdButton.setTitle("Loading..", for: .normal)
        loadAdButton.isEnabled = false
        interstitial?.loadAd()
        
        
    }

    @IBAction func showAd(_ sender: Any) {
        print("Showing Ad now")
        interstitial?.showAd()
    }
    
    
    func setInterstitialReady(_ ready:Bool){
        interstitialReady = ready
        loadAdButton.setTitle("Load Ad", for: .normal)
        loadAdButton.isEnabled = true
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

    func onAdClicked() {
        print("Interstitial :: clicked")
    }
}

