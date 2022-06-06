import Foundation
import UIKit
import WebKit

public class TempoInterstitialView: UIViewController, WKNavigationDelegate, WKScriptMessageHandler  {
    private var interstitial:TempoInterstitial!
    public var delegate:TempoInterstitialDelegate!
    
    var webView:WKWebView!

    public func loadURLInterstitial(interstitial:TempoInterstitial){
        self.interstitial = interstitial
        self.setupWKWebview()
        self.loadPage()
        
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        delegate.interstitialReady(self.interstitial)
        
        print("load url interstitial")
        self.view.backgroundColor = UIColor.red
    }
    
    private func loadPage() {
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
        }
    }
    
    public func display(_ parentViewController:UIViewController) {
        parentViewController.view.addSubview(webView)
    }
    
}
