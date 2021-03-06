import Foundation
import UIKit

public class TempoInterstitial: NSObject {
    private var interstitialView:TempoInterstitialView?
    public var parentViewController:UIViewController?
    
    public init(parentViewController:UIViewController?, delegate:TempoInterstitialListener){
        super.init()
        self.parentViewController = parentViewController
        interstitialView = TempoInterstitialView()
        interstitialView!.listener = delegate
    }
    
    public func updateViewController(parentViewController:UIViewController?){
        self.parentViewController = parentViewController
    }
    
    public func loadAd(){
        interstitialView!.loadAd(interstitial:self)
    }
    
    public func showAd(){
        interstitialView!.showAd(parentViewController: parentViewController!)
    }
}
