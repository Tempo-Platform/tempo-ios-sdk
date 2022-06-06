public protocol TempoInterstitialDelegate {
    // called when the interstitial content is finished loading
    func interstitialReady(_ interstitial:TempoInterstitial)
    
    // called when an error occurs loading the interstitial content
    func interstitialFailedToLoad(_ interstitial:TempoInterstitial)
    
    // called when the interstitial has close, and disposed of it's views
    func interstitialClosed(_ interstitial:TempoInterstitial)
    
    // called when the HTML request starts to load
    func interstitialStartLoad(_ interstitial:TempoInterstitial)
}
