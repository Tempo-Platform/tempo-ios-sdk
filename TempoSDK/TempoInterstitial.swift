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
        print("Area: \(TempoUserInfo.getIsoCountryCode2Digit())");
        self.parentViewController = parentViewController
        interstitialView = TempoInterstitialView()
        interstitialView!.listener = delegate
        
        interstitialView!.utcGenerator = TempoUtcGenerator()
        let advertisingIdentifier: UUID = ASIdentifierManager().advertisingIdentifier
        // TODO: add proper IDFA alternative here if we don't have advertisingIdentifier
        self.adId = (advertisingIdentifier.uuidString != "00000000-0000-0000-0000-000000000000") ? advertisingIdentifier.uuidString : nil
        self.appId = appId
    }
    
    public func updateViewController(parentViewController:UIViewController?){
        self.parentViewController = parentViewController
    }

    public func updateAppId(appId:String){
        self.appId = appId
    }
    
    public func loadSpecificAd(isInterstitial: Bool, campaignId:String){
        interstitialView!.loadSpecificAd(isInterstitial: isInterstitial, campaignId: campaignId)
    }
    
    public func loadAd(isInterstitial: Bool, cpmFloor: Float?, placementId: String?){
        interstitialView!.utcGenerator.resyncNtp()
        interstitialView!.loadAd(interstitial: self, isInterstitial: isInterstitial, appId: appId!, adId: adId, cpmFloor: cpmFloor, placementId: placementId)
    }
    
    public func showAd(){
        interstitialView!.showAd(parentViewController: parentViewController!)
    }
    
    public func closeAd(){
        interstitialView!.closeAd()
    }
}
