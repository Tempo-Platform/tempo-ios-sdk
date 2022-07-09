import Foundation
import UIKit
import WebKit

public class TempoInterstitialView: UIViewController, WKNavigationDelegate, WKScriptMessageHandler  {
    public var listener:TempoInterstitialListener!
    private var observation: NSKeyValueObservation?
    var webView:WKWebView!

    public func loadAd(interstitial:TempoInterstitial){
        print("load url interstitial")
        self.setupWKWebview()
        self.loadUrl()
    }
    
    public func showAd(parentViewController:UIViewController) {
        
        if #available(iOS 15.0, *) {
            webView.setAllMediaPlaybackSuspended(false)
        }
        parentViewController.view.addSubview(webView)
        webView.isHidden = false;
        listener.onAdDisplayed()
    }
    
    private func loadUrl() {
        var request = URLRequest(url: URL(string: "https://tempo.free.beeceptor.com/json")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, Int>
                DispatchQueue.main.async {
//                    let url = URL(string: "https://dedc-49-205-147-202.ngrok.io/campaign/\(json["id"]!)/ios")!
                    let url = URL(string: "https://brands.tempoplatform.com/campaign/\(json["id"]!)/ios")!
                    self.webView.load(URLRequest(url: url))
                }
            } catch {
                DispatchQueue.main.async {
                    self.listener.onAdFetchFailed()
                }
                print("Tempo SDK: Failed loading the Ad.")
            }
        })
        task.resume()
    }
    
    private func setupWKWebview() {
        webView = WKWebView(frame: self.view.bounds, configuration: self.getWKWebViewConfiguration())
        webView.scrollView.bounces = false
        webView.isHidden = true;
        if #available(iOS 15.0, *) {
            UIApplication.shared.windows.last?.addSubview(webView)
        }
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
    }
    
    private func getWKWebViewConfiguration() -> WKWebViewConfiguration {
        let userController = WKUserContentController()
        userController.add(self, name: "observer")
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userController
        configuration.allowsInlineMediaPlayback = true
        if #available(iOS 10.0, *) {
           configuration.mediaTypesRequiringUserActionForPlayback = []
        }
        return configuration
    }
        
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if(message.body as? String == "TEMPO_CLOSE_AD"){
            webView.removeFromSuperview()
            webView = nil
            listener.onAdClosed()
        }
        
        if(message.body as? String == "TEMPO_ASSETS_LOADED"){
            print("TEMPO_ASSETS_LOADED")
            listener.onAdFetchSucceeded()
        }
        
        if(message.body as? String == "TEMPO_VIDEO_LOADED"){
            if #available(iOS 15.0, *) {
                webView.setAllMediaPlaybackSuspended(true)
                webView.removeFromSuperview()
            } else {
                
            }
            print("TEMPO_VIDEO_LOADED")
        }
        
        if(message.body as? String == "TEMPO_IMAGES_LOADED"){
            print("TEMPO_IMAGES_LOADED")
        }
        
    }
    
}
