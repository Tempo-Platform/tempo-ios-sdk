import Foundation
import UIKit
import WebKit

public class TempoInterstitialView: UIViewController, WKNavigationDelegate, WKScriptMessageHandler  {
    public var listener:TempoInterstitialListener!
    
    var webView:WKWebView!

    public func loadAd(interstitial:TempoInterstitial){
        print("load url interstitial")
        self.setupWKWebview()
        self.loadUrl()
        
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        listener.onAdFetchSucceeded()
    }
    
    public func showAd(parentViewController:UIViewController) {
        parentViewController.view.addSubview(webView)
        listener.onAdDisplayed()
    }
    
    private func loadUrl() {
        let url = URL(string: "https://brands.tempoplatform.com/campaign/1/ios")!
        self.webView.load(URLRequest(url: url))
    }
    
    private func setupWKWebview() {
        self.webView = WKWebView(frame: self.view.bounds, configuration: self.getWKWebViewConfiguration())
    }
    
    private func getWKWebViewConfiguration() -> WKWebViewConfiguration {
        let userController = WKUserContentController()
        userController.add(self, name: "observer")
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userController
        return configuration
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.body as? String == "CLOSE_AD"){
            webView.removeFromSuperview()
            listener.onAdClosed()
        }
    }
    
}
