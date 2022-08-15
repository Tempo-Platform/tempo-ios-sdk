import Foundation
import UIKit
import WebKit

class FullScreenWKWebView: WKWebView {
    override var safeAreaInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

public struct Metric : Codable {
    var metric_type: String?
    var ad_id: String?
    var app_id: String?
    var timestamp: Int?
    var bundle_id: String = "unknown"
    var campaign_id: String = "unknown"
    var session_id: String = "unknown"
    var location: String = "unknown"
    var gender: String = "?"
    var age_range: String = "unknown"
    var income_range: String = "unknown"
    var os: String = "unknown"
//    var additional_metrics: Dictionary<String, Any>? = nil
}

public class TempoInterstitialView: UIViewController, WKNavigationDelegate, WKScriptMessageHandler  {
    public var listener:TempoInterstitialListener!
    private var observation: NSKeyValueObservation?
    var webView:FullScreenWKWebView!
    var metricList: [Metric] = []
    var currentUUID: String?
    var currentAdId: String?
    var currentCampaignId: String?
    var currentAppId: String?

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
        pushMetrics()
        listener.onAdClosed()
    }
    
    private func loadUrl(appId:String, adId:String?) {
        currentUUID = UUID().uuidString
        currentAdId = adId ?? "NONE"
        currentAppId = appId
        metricList.append(Metric(metric_type: "AD_LOAD_REQUEST",
                                 ad_id: currentAdId,
                                 app_id: appId,
                                 timestamp: Int(NSDate().timeIntervalSince1970 * 1000),
                                 bundle_id: Bundle.main.bundleIdentifier!,
                                 campaign_id: "N/A",
                                 session_id: currentUUID!,
                                 os: "iOS \(UIDevice.current.systemVersion)"))
        var components = URLComponents(string: "https://ads-api.tempoplatform.com/ad/")!
        components.queryItems = [
            URLQueryItem(name: "uuid", value: currentUUID),  // this UUID is unique per ad load
            URLQueryItem(name: "ad_id", value: currentAdId),
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
                    self.metricList.append(Metric(metric_type: "NO_FILL",
                                                  ad_id: self.currentAdId,
                                                  app_id: appId,
                                                  timestamp: Int(NSDate().timeIntervalSince1970 * 1000),
                                                  bundle_id: Bundle.main.bundleIdentifier!,
                                                  campaign_id: "N/A",
                                                  session_id: self.currentUUID!,
                                                  os: "iOS \(UIDevice.current.systemVersion)"))
                } else {
                    DispatchQueue.main.async {
                        let url = URL(string: "https://brands.tempoplatform.com/campaign/\(json["id"]!)/ios")!
                        self.currentCampaignId = (json["id"] as! String)
    //                    let url = URL(string: "https://f8e8-49-205-146-88.ngrok.io/campaign/\(json["id"]!)/ios")!
                        self.webView.load(URLRequest(url: url))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.listener.onAdFetchFailed()
                }
                print("Tempo SDK: Failed loading the Ad.")
                self.metricList.append(Metric(metric_type: "AD_LOAD_FAILED",
                                              ad_id: self.currentAdId,
                                              app_id: appId,
                                              timestamp: Int(NSDate().timeIntervalSince1970 * 1000),
                                              bundle_id: Bundle.main.bundleIdentifier!,
                                              campaign_id: "N/A",
                                              session_id: self.currentUUID!,
                                              os: "iOS \(UIDevice.current.systemVersion)"))
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
            self.metricList.append(Metric(metric_type: "AD_LOAD_SUCCESS",
                                          ad_id: currentAdId,
                                          app_id: currentAppId,
                                          timestamp: Int(NSDate().timeIntervalSince1970 * 1000),
                                          bundle_id: Bundle.main.bundleIdentifier!,
                                          campaign_id: currentCampaignId!,
                                          session_id: currentUUID!,
                                          os: "iOS \(UIDevice.current.systemVersion)"))
        }
        
    }

    private func pushMetrics() {
        //create the url with NSURL
        let url = URL(string: "http://metric-api.tempoplatform.com/metrics/")!

        //create the session object
        let session = URLSession.shared

        //now create the Request object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST

        let metricData = try? JSONEncoder().encode(metricList)

        request.httpBody = metricData // pass dictionary to data object and set it as request body

        //HTTP Headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request, completionHandler: { data, response, error in

            guard error == nil else {
                return
            }
        })
        task.resume()
    }
    
}
