//
//  TempoTesting.swift
//  TempoSDK
//
//  Created by Stephen Baker on 24/7/2023.
//

import Foundation

public class TempoTesting {
    
    private static var instance: TempoTesting?
    
    init() {
        TempoTesting.instance = self
    }
    
    func toggleTesting() -> Void {
        Constants.IS_TESTING = !Constants.IS_TESTING
    }
    
    func updateEnvironment(isProd: Bool) -> Void {
        Constants.IS_PROD = isProd
    }
    
    func activateUseOfDeployVersion(activate: Bool) -> Void {
        Constants.isTestingDeployVersion = activate
    }
    
    func updateDeployVersion(newVersion: String) -> Void {
        Constants.currentDeployVersion = newVersion
    }
    
    func activateCustomCampaignIdsForInterstitialAds(activate: Bool) -> Void {
        Constants.isTestingCustomCampaignIdsForInterstitialAds = activate
    }
    
    func activateCustomCampaignIdsForRewardedAds(activate: Bool) -> Void {
        Constants.isTestingCustomCampaignIdsForRewardedAds = activate
    }
    
    func updateCampaignForInterstitialAd(newVersion: String) -> Void {
        Constants.customCampaignIdForInterstitial = newVersion
    }
    
    func updateCampaignForRewardedAd(newVersion: String) -> Void {
        Constants.customCampaignIdForRewarded = newVersion
    }
}
