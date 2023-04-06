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
        
        let currentLocale = Locale.current
        let currencyCode = currentLocale.currencyCode
        let regionLocale = currentLocale.identifier
        let locale = NSLocale(localeIdentifier: regionLocale)
        guard let countryCode = currentLocale.regionCode else {
            print("ERROR: region code was nil")
            return
        }
        print("🎬 Init triggered: \(currencyCode ?? "<currencyCodeInvalid>") | \(regionLocale) | \(countryCode)")
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
