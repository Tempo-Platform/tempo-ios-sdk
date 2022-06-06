import Foundation
import TempoSDK

class SDKConsumer : NSObject {
    var interstitialDelegate:TempoInterstitialDelegate? = nil
    var parentViewController:ViewController!
    
    var interstitial:TempoInterstitial? = nil
    var log:(String)->Void = { str in }
    
    init(parentViewController:ViewController) {
        self.parentViewController = parentViewController
        super.init()
    }
    
    func setInterstitialDelegate(_ delegate:TempoInterstitialDelegate){
        self.interstitialDelegate = delegate
    }
    
    func setLoggingFunction(_ log:@escaping (String) -> Void){
        self.log = log
    }
    
    func displayInterstitial(){
        self.interstitial?.display()
    }

    func getInterstitial(){
        self.interstitial = TempoInterstitial(parentViewController:self.parentViewController, delegate:self.interstitialDelegate!)

    }
}
