import Foundation
import UIKit
import WebKit

class FullScreenWKWebView: WKWebView {
    override var safeAreaInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

public class TempoInterstitialView: UIViewController, WKNavigationDelegate, WKScriptMessageHandler  {
    public var listener:TempoInterstitialListener!
    private var observation: NSKeyValueObservation?
    var webView:FullScreenWKWebView!

    public func loadAd(interstitial:TempoInterstitial, appId:String, adId:String?){
        print("load url interstitial")
        self.setupWKWebview()
        self.loadUrl(appId:appId, adId:adId)
    }
    
    public func showAd(parentViewController:UIViewController) {
        parentViewController.view.addSubview(webView)
//        webView.isHidden = false;
        listener.onAdDisplayed()
    }
    
    public func closeAd(){
        webView.removeFromSuperview()
        webView = nil
        listener.onAdClosed()
    }
    
    private func loadUrl(appId:String, adId:String?) {
        var components = URLComponents(string: "https://ads-api.tempoplatform.com/ad/")!
        components.queryItems = [
            URLQueryItem(name: "uuid", value: UUID().uuidString),  // TODO: write this UUID somewhere? per publisher?
            URLQueryItem(name: "ad_id", value: adId ?? "NONE"),  // TODO: add proper IDFA alternative here
            URLQueryItem(name: "app_id", value: appId)
        ]
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, Any>
                if (json["status"] as! String == "NO_FILL") {
                    DispatchQueue.main.async {
                        self.listener.onAdFetchFailed()
                    }
                    print("Tempo SDK: Failed loading the Ad. Received NO_FILL response from API.")
                } else {
                    DispatchQueue.main.async {
                        let url = URL(string: "https://brands.tempoplatform.com/campaign/\(json["id"]!)/ios")!
    //                    let url = URL(string: "https://f8e8-49-205-146-88.ngrok.io/campaign/\(json["id"]!)/ios")!
                        self.webView.load(URLRequest(url: url))
                    }
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
        webView = FullScreenWKWebView(frame: UIScreen.main.bounds, configuration: self.getWKWebViewConfiguration())
        webView.scrollView.bounces = false
//        webView.isHidden = true;
//        UIApplication.shared.windows.last?.addSubview(webView)
        
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
            self.closeAd()
        }
        
        if(message.body as? String == "TEMPO_ASSETS_LOADED"){
            print("TEMPO_ASSETS_LOADED")
        }
        
        
        if(message.body as? String == "TEMPO_VIDEO_LOADED"){
            print("TEMPO_VIDEO_LOADED")
        }
        
        if(message.body as? String == "TEMPO_IMAGES_LOADED"){
            print("TEMPO_IMAGES_LOADED")
            listener.onAdFetchSucceeded()
        }
        
    }
    
}
