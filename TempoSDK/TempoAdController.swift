import Foundation
import UIKit
import AdSupport

/**
 *  Initialises when app loads. This is the object that mediation adapters call to load/show ads
 */
public class TempoAdController: NSObject { // TempoInterstitial
    
    public var parentViewController: UIViewController?
    public var appId: String?
    public var adId: String?
    public var adapterVersion: String?
    public var sdkVersion = Constants.SDK_VERSIONS;
    public var hasUserConsent: Bool?
    
    var adView: TempoAdView?
    
    public init(parentViewController: UIViewController?, delegate: TempoAdListener, appId: String) {
        super.init()
        
        // Update class varaibles
        self.parentViewController = parentViewController
        self.appId = appId
        
        // Create AdView object
        adView = TempoAdView()
        adView!.listener = delegate
        
        // Check version of SDK/Adapters
        adapterVersion = adView!.listener.onVersionExchange(sdkVersion: self.sdkVersion)
        
        // Get Advertising ID (IDFA) // TODO: add proper IDFA alternative here if we don't have advertisingIdentifier
        let advertisingIdentifier: UUID = ASIdentifierManager().advertisingIdentifier
        self.adId = (advertisingIdentifier.uuidString != "00000000-0000-0000-0000-000000000000") ? advertisingIdentifier.uuidString : nil
        
        // Check for backups
        adView?.checkHeldMetrics()
        
        print("TempoSDK: [SDK]\(sdkVersion)/[ADAP]\(adapterVersion ?? Constants.UNDEF) | AppID: \(self.appId ?? Constants.UNDEF)")
    }
    

    
    public func loadSpecificAd(isInterstitial: Bool, campaignId:String){
        adView!.loadSpecificCampaignAd(isInterstitial: isInterstitial, campaignId: campaignId)
    }
    
    public func loadAd(isInterstitial: Bool, cpmFloor: Float?, placementId: String?){

        //interstitialView!.utcGenerator.resyncNtp()
        adView!.loadAd(interstitial: self, isInterstitial: isInterstitial, appId: appId!, adId: adId, cpmFloor: cpmFloor, placementId: placementId, sdkVersion: sdkVersion, adapterVersion: adapterVersion )
    }
    
    
    public func showAd() { adView!.showAd(parentViewController: parentViewController!)  }
    
    public func closeAd(){   adView!.closeAd()    }
    
    
    
    
    
    // NEEDED ANYMORE???
    public func updateViewController(parentViewController: UIViewController?) {
        self.parentViewController = parentViewController
    }

    public func updateAppId(appId:String){
        self.appId = appId
    }
}
