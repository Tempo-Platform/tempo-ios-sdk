//
//  TempoTesting.swift
//  TempoSDK
//
//  Created by Stephen Baker on 24/7/2023.
//

import Foundation

public class TempoTesting {
    
    public static var instance: TempoTesting?
    
    public init() {
        TempoTesting.instance = self
    }
    
    public func toggleTesting() -> Void {
        Constants.IS_TESTING = !Constants.IS_TESTING
    }
    
    public func updateEnvironment(isProd: Bool) -> Void {
        Constants.IS_PROD = isProd
    }
    
    public func activateUseOfDeployVersion(activate: Bool) -> Void {
        Constants.isTestingDeployVersion = activate
    }
    
    public func updateDeployVersion(newVersion: String) -> Void {
        Constants.currentDeployVersion = newVersion
    }
    
    public func activateCustomCampaignIdsForInterstitialAds(activate: Bool) -> Void {
        Constants.isTestingCustomCampaignIdsForInterstitialAds = activate
    }
    
    public func activateCustomCampaignIdsForRewardedAds(activate: Bool) -> Void {
        Constants.isTestingCustomCampaignIdsForRewardedAds = activate
    }
    
    public func updateCampaignForInterstitialAd(newVersion: String) -> Void {
        Constants.customCampaignIdForInterstitial = newVersion
    }
    
    public func updateCampaignForRewardedAd(newVersion: String) -> Void {
        Constants.customCampaignIdForRewarded = newVersion
    }
}
