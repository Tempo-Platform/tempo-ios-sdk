import Foundation
import UIKit

/**
 *  Initialises when app loads. This is the object that mediation adapters call to load/show ads
 */
public class TempoAdController: NSObject {
    
    static var isInitialised: Bool = false
    public var adView: TempoAdView?
    public var locationData: LocationData? = nil
    static var tempoProfile: TempoProfile? = nil
    
    public init(tempoAdListener: TempoAdListener, appId: String!) {
        super.init()
        
        // On first instantiation by either ad type do some initial global checks
        if(!TempoAdController.isInitialised) {
            
            // Check for backups
            TempoDataBackup.checkHeldMetrics(completion: Metrics.pushMetrics)
            
            // Show as initialised moving forward and ignore this section
            TempoAdController.isInitialised = true;
        }
        
        // Create AdView object
        adView = TempoAdView(listener: tempoAdListener, appId: appId)
    }
    
    /// Public LOAD function for mediation adapters to call
    public func loadAd(isInterstitial: Bool, cpmFloor: Float?, placementId: String?) {
        
        // Load ad when checks are done
        adView!.loadAd (
            isInterstitial: isInterstitial,
            cpmFloor: cpmFloor,
            placementId: placementId)
    }
    
    /// Creates TempoLocation object and calls checker function with handler callback
    public func checkLocationConsentAndLoad(isInterstitial: Bool, cpmFloor: Float?, placementId: String?) {
        TempoAdController.tempoProfile = TempoProfile()
        TempoAdController.tempoProfile?.checkLocationServicesConsent(completion: self.handleLocationConsentAndLoadAd, isInterstitial: isInterstitial, cpmFloor: cpmFloor, placementId: placementId)
    }
    
    /// Consent callback handler that updates global value for metrics and loads ad
    public func handleLocationConsentAndLoadAd(locData: LocationData, isInterstitial: Bool, cpmFloor: Float?, placementId: String?) {
        adView?.locationConsent = locData.location_consent ?? ""
        adView?.locationData = locData
        TempoUtils.Say(msg: "TempoLocationConsent: \(locData)")
        
        DispatchQueue.main.async {
            self.loadAd(isInterstitial: isInterstitial, cpmFloor: cpmFloor, placementId: placementId)
        }
    }
    
    /// Public SHOW function for mediation adapters to call
    public func showAd(parentViewController: UIViewController?) {
        adView!.showAd(parentVC: parentViewController)
    }
    
    /// Public LOAD function for internal testing with specific campaign ID
    public func loadSpecificAd(isInterstitial: Bool, campaignId:String){
        adView!.loadSpecificCampaignAd(
            isInterstitial: isInterstitial,
            campaignId: campaignId)
    }
}
