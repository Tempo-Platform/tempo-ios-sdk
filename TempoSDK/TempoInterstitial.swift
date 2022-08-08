import Foundation
import UIKit
import AdSupport

public class TempoInterstitial: NSObject {
    private var interstitialView:TempoInterstitialView?
    public var parentViewController:UIViewController?
    public var appId:String?
    public var adId:String?
    
    public init(parentViewController:UIViewController?, delegate:TempoInterstitialListener, appId:String){
        super.init()
        self.parentViewController = parentViewController
        interstitialView = TempoInterstitialView()
        interstitialView!.listener = delegate
        let advertisingIdentifier: UUID = ASIdentifierManager().advertisingIdentifier
        self.adId = (advertisingIdentifier.uuidString != "00000000-0000-0000-0000-000000000000") ? advertisingIdentifier.uuidString : nil
        self.appId = appId
    }
    
    public func updateViewController(parentViewController:UIViewController?){
        self.parentViewController = parentViewController
    }
    
    public func loadAd(){
        interstitialView!.loadAd(interstitial:self, appId:appId!, adId:adId)
    }
    
    public func showAd(){
        interstitialView!.showAd(parentViewController: parentViewController!)
    }
    
    public func closeAd(){
        interstitialView!.closeAd()
    }
}
