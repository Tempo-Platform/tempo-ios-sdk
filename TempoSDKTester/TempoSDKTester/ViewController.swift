import TempoSDK
import UIKit

class ViewController: UIViewController, TempoInterstitialDelegate {

    @IBOutlet weak var loadAd: UIButton!
    var interstitialReady:Bool = false
    var sdk:SDKConsumer! = nil
    
    @IBAction func loadAd(_ sender: Any) {
        print("load Ad was clicked")
        sdk = SDKConsumer(parentViewController:self)
        sdk.setInterstitialDelegate(self)
        sdk.getInterstitial()
        sdk.displayInterstitial()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func setInterstitialReady(_ ready:Bool){
        interstitialReady = ready
//        btnDisplayInterstitial.isHidden = !ready
    }
    
    func interstitialReady(_ interstitial: TempoInterstitial) {
        print("Interstitial :: ready")
        setInterstitialReady(true)
    }
    
    func interstitialFailedToLoad(_ interstitial: TempoInterstitial) {
        print("Interstitial :: failed")
    }
    
    func interstitialClosed(_ interstitial: TempoInterstitial) {
        print("Interstitial :: close")
    }
    
    func interstitialStartLoad(_ interstitial: TempoInterstitial) {
        print("Interstitial :: start load")
    }
    

}

