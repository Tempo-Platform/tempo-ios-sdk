public protocol TempoInterstitialListener {
    // called when the interstitial content is finished loading
    func onAdFetchSucceeded()
    
    // called when an error occurs loading the interstitial content
    func onAdFetchFailed()
    
    // called when the interstitial has close, and disposed of it's views
    func onAdClosed()
    
    // Called when an ad goes full screen.
    func onAdDisplayed()
}
