public protocol TempoInterstitialListener {
    // Called when the interstitial content is finished loading.
    func onAdFetchSucceeded()
    
    // Called when an error occurs loading the interstitial content.
    func onAdFetchFailed()
    
    // Called when the interstitial has closed and disposed of its views.
    func onAdClosed()
    
    // Called when an ad goes full screen.
    func onAdDisplayed()
    
    // Called when an ad is clicked.
    func onAdClicked()  // TODO: actually monitor clicks and call this callback
}
