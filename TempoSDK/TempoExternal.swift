import Foundation

public class TempoExternal {
    
    public static var instance: TempoExternal?
    
    public var isTestingDeployVersion: Bool = false
    public var isTestingCustomCampaigns: Bool = false
    public var currentDeployVersion: String?
    public var customCampaignId: String?
    public var customUrl: String?
    public var usingNextJS: Bool = false
    public var usingCustomUrl: Bool = false
    
    public init() {
        TempoExternal.instance = self
    }
    
    public func toggleVerboseDebugging() -> Void {
        Constants.isVerboseDebugging = !Constants.isVerboseDebugging
    }
    
    public func updateEnvironment(isProd: Bool) -> Void {
        //Constants.isProd = isProd
    }
    
    public func updateEnvironmentWithIndex(enumValue: Int) -> Void {
        Constants.environment = Constants.Environment.allValues[enumValue]
    }
    
    public func activateUseOfDeployVersion(activate: Bool) -> Void {
        isTestingDeployVersion = activate
    }
    
    public func updateDeployVersion(newVersion: String) -> Void {
        currentDeployVersion = newVersion
    }
    
    public func activateCustomCampaigns(activate: Bool) -> Void {
        isTestingCustomCampaigns = activate
    }
    
    public func toggleURLForNextjs(isOn: Bool) -> Void {
        usingNextJS = isOn
    }
    
    public func toggleCustomUrl(isOn: Bool) -> Void {
        usingCustomUrl = isOn
    }
    
    public func updateCustomCampaignId(campaignId: String) -> Void {
        customCampaignId = campaignId
    }
    
    public func updateCustomUrl(url: String) -> Void {
        customUrl = url
    }
    
    public func disableProfile() {
        TempoProfile.locationState = LocationState.DISABLED
    }
}
