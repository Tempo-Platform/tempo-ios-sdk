import Foundation
import UIKit

public class TempoInterstitial: NSObject {
    private var interstitialView:TempoInterstitialView?
    private var parentViewController:UIViewController?
    
    public init(parentViewController:UIViewController?, delegate:TempoInterstitialListener){
        super.init()
        self.parentViewController = parentViewController
        interstitialView = TempoInterstitialView()
        interstitialView!.listener = delegate
    }
    
    public func loadAd(){
        interstitialView!.loadAd(interstitial:self)
    }
    
    public func showAd(){
        interstitialView!.showAd(parentViewController: parentViewController!)
    }
}
