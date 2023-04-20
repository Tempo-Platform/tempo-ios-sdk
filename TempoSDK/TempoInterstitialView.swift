import Foundation
import UIKit
import WebKit

class FullScreenWKWebView: WKWebView {
    override var safeAreaInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
    }
}

class FullScreenUIView: UIView {
    override var safeAreaInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

@available(iOS 13.0, *)
func getSafeAreaTop()->CGFloat{
    let keyWindow = UIApplication.shared.connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
        .filter({$0.isKeyWindow}).first
    
    return keyWindow?.safeAreaInsets.top ?? 0
}

@available(iOS 13.0, *)
func getSafeAreaBottom()->CGFloat{
    let keyWindow = UIApplication.shared.connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
        .filter({$0.isKeyWindow}).first
    
    return keyWindow?.safeAreaInsets.bottom ?? 0
}

public struct Metric : Codable {
    var metric_type: String?
    var ad_id: String?
    var app_id: String?
    var timestamp: Int?
    var is_interstitial: Bool?
    var bundle_id: String = "unknown"
    var campaign_id: String = "unknown"
    var session_id: String = "unknown"
    var location: String = "unknown"
    var gender: String = "?"
    var age_range: String = "unknown"
    var income_range: String = "unknown"
    var placement_id: String = "unknown"
    var country_code: String? = TempoUserInfo.getIsoCountryCode2Digit()
    var os: String = "unknown"
}

public class TempoInterstitialView: UIViewController, WKNavigationDelegate, WKScriptMessageHandler  {
    public var listener:TempoInterstitialListener!
    public var utcGenerator: TempoUtcGenerator!
    private var observation: NSKeyValueObservation?
    var solidColorView:FullScreenUIView!
    var webView:FullScreenWKWebView!
    var metricList: [Metric] = []
    var currentUUID: String?
    var currentAdId: String?
    var currentCampaignId: String?
    var currentAppId: String?
    var currentPlacementId: String?
    var currentIsInterstitial: Bool?
    var currentParentViewController: UIViewController?
    var previousParentBGColor: UIColor?

    public func loadAd(interstitial:TempoInterstitial, isInterstitial: Bool, appId:String, adId:String?, cpmFloor:Float?, placementId: String?) {
        print("load url interstitial")
        self.setupWKWebview()
        self.loadUrl(isInterstitial:isInterstitial, appId:appId, adId:adId, cpmFloor:cpmFloor, placementId: placementId)
    }
    
    public func showAd(parentViewController:UIViewController) {
        self.currentParentViewController = parentViewController
        self.currentParentViewController!.view.addSubview(solidColorView)
        addMetric(metricType: "AD_SHOW")
        listener.onAdDisplayed(isInterstitial: self.currentIsInterstitial ?? true)
    }
    
    public func closeAd(){
        solidColorView.removeFromSuperview()
        webView.removeFromSuperview()
        webView = nil
        solidColorView = nil
        pushMetrics(backupUrl: nil)
        listener.onAdClosed(isInterstitial: self.currentIsInterstitial ?? true)
    }
    
    public func loadSpecificAd(isInterstitial: Bool, campaignId:String) {
        print("load specific url interstitial")
        self.setupWKWebview()
        currentUUID = "TEST"
        currentAdId = "TEST"
        currentAppId = "TEST"
        currentIsInterstitial = isInterstitial
        let urlComponent = isInterstitial ? "interstitial" : "campaign"
        self.addMetric(metricType: "CUSTOM_AD_LOAD_REQUEST")
        let url = URL(string: "https://ads.tempoplatform.com/\(urlComponent)/\(campaignId)/ios")!
        self.currentCampaignId = campaignId
        self.webView.load(URLRequest(url: url))
    }
    
    private func loadUrl(isInterstitial: Bool, appId:String, adId:String?, cpmFloor:Float?, placementId: String?) {
        currentUUID = UUID().uuidString
        currentAdId = adId ?? "NONE"
        currentAppId = appId
        currentIsInterstitial = isInterstitial
        currentPlacementId = placementId
        let currentCPMFloor = cpmFloor ?? 0.0
        self.addMetric(metricType: "AD_LOAD_REQUEST")
        var components = URLComponents(string: "https://ads-api.tempoplatform.com/ad")!
        components.queryItems = [
            URLQueryItem(name: "uuid", value: currentUUID),  // this UUID is unique per ad load
            URLQueryItem(name: "ad_id", value: currentAdId),
            URLQueryItem(name: "app_id", value: appId),
            URLQueryItem(name: "cpm_floor", value: String(describing: currentCPMFloor)),
            URLQueryItem(name: "is_interstitial", value: String(currentIsInterstitial!)),
        ]
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if error != nil || data == nil {
                DispatchQueue.main.async {
                    self.sendAdFetchFailed()
                }
            } else {
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    DispatchQueue.main.async {
                        self.sendAdFetchFailed()
                    }
                    return
                }
                do {
                    var didSomething = false
                    let json = try JSONSerialization.jsonObject(with: data!)
                    DispatchQueue.main.async {
                        if let jsonDict = json as? Dictionary<String, Any> {
                            if let status = jsonDict["status"] {
                                if let statusString = status as? String {
                                    if statusString == "NO_FILL" {
                                        self.listener.onAdFetchFailed(isInterstitial: self.currentIsInterstitial ?? true)
                                        print("Tempo SDK: Failed loading the Ad. Received NO_FILL response from API.")
                                        self.addMetric(metricType: "NO_FILL")
                                        didSomething = true
                                    } else if (statusString == "OK") {
                                        if let id = jsonDict["id"] {
                                            if let idString = id as? String {
                                                print("Tempo SDK: Got Ad ID from server. Response \(jsonDict).")
                                                let urlComponent = self.currentIsInterstitial! ? "interstitial" : "campaign"
                                                let url = URL(string: "https://ads.tempoplatform.com/\(urlComponent)/\(idString)/ios")!
                                                self.currentCampaignId = idString
                                                self.webView.load(URLRequest(url: url))
                                                didSomething = true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        if (!didSomething) {
                            self.sendAdFetchFailed()
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.sendAdFetchFailed()
                    }
                }
            }
        })
        task.resume()
    }
    
    private func sendAdFetchFailed() {
        self.listener.onAdFetchFailed(isInterstitial: self.currentIsInterstitial ?? true)
        print("Tempo SDK: Failed loading the Ad. Reason unknown.")
        self.addMetric(metricType: "AD_LOAD_FAILED")
    }
    
    private func setupWKWebview() {
        var safeAreaTop: CGFloat
        var safeAreaBottom: CGFloat
        if #available(iOS 13.0, *) {
            safeAreaTop = getSafeAreaTop()
            safeAreaBottom = getSafeAreaBottom()
        } else {
            safeAreaTop = 0.0
            safeAreaBottom = 0.0
        }
        webView = FullScreenWKWebView(frame: CGRect(
            x: 0,
            y: safeAreaTop,
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height - safeAreaTop - safeAreaBottom
        ), configuration: self.getWKWebViewConfiguration())
        webView.scrollView.bounces = false
        
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        solidColorView = FullScreenUIView(frame: CGRect( x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
        // ".black/#000" treated as transparent in Unity so making it a 'pseudo-black'
        solidColorView.backgroundColor = UIColor(red: 0.01, green: 0.01, blue:0.01, alpha: 1)
        solidColorView.addSubview(webView)
    }
    
    private func getWKWebViewConfiguration() -> WKWebViewConfiguration {
        let userController = WKUserContentController()
        userController.add(self, name: "observer")
        
        // Create script that locks scalability and add to WK content controller
        let lockScaleSource: String = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" +
            "head.appendChild(meta);"
        let lockScaleScript: WKUserScript = WKUserScript(source: lockScaleSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        userController.addUserScript(lockScaleScript)
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userController
        configuration.allowsInlineMediaPlayback = true
        if #available(iOS 10.0, *) {
           configuration.mediaTypesRequiringUserActionForPlayback = []
        }
    
        return configuration
    }
        
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.body as? String != nil){
            self.addMetric(metricType: message.body as! String)
        }
        
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
            listener.onAdFetchSucceeded(isInterstitial: self.currentIsInterstitial ?? true)
            self.addMetric(metricType: "AD_LOAD_SUCCESS")
        }
        
        if(message.body as? String == "TIMER_COMPLETED"){
            print("TIMER_COMPLETED")
        }
    }

    private func addMetric(metricType: String) {
        var deviceTime: Bool = false
        let metric = Metric(metric_type: metricType,
                            ad_id: currentAdId,
                            app_id: currentAppId,
                            timestamp: utcGenerator.getUTCTime(deviceTime: &deviceTime),
                            is_interstitial: currentIsInterstitial,
                            bundle_id: Bundle.main.bundleIdentifier!,
                            campaign_id: currentCampaignId ?? "",
                            session_id: currentUUID!,
                            placement_id: currentPlacementId ?? "",
                            os: "iOS \(UIDevice.current.systemVersion)")
        
        self.metricList.append(metric)
        if (["AD_SHOW", "AD_LOAD_REQUEST", "TIMER_COMPLETED"].contains(metricType)) {
            pushMetrics(backupUrl: nil)
        }
        //print("MetricTime: \(metric.timestamp!)")
        
        // If metric using device time, send additional metric instance
        if(deviceTime)
        {
            addDeviceTimeMetric(metric: metric)
        }
    }
    
    private func addDeviceTimeMetric(metric: Metric) {
        print("DEVICE_TIME metric sent")
        self.metricList.append(Metric(metric_type: "DEVICE_TIME",
                                      ad_id: metric.ad_id,
                                      app_id: metric.app_id,
                                      timestamp: metric.timestamp,
                                      is_interstitial: metric.is_interstitial,
                                      bundle_id: metric.bundle_id,
                                      campaign_id: metric.campaign_id,
                                      session_id: metric.session_id,
                                      placement_id: metric.placement_id,
                                      os: metric.os))
        pushMetrics(backupUrl: nil)
    }
    
    private func pushMetrics(backupUrl: URL?) {
        
        //create the url with NSURL
        let url = URL(string: TempoConstants.METRIC_SERVER_URL)!
        
        //create the session object
        let session = URLSession.shared
        
        //now create the Request object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        
        // Prints out metrics types being sent in this push
        if(TempoConstants.IS_DEBUGGING)
        {
            var outMetricList = backupUrl != nil ? TempoDataBackup.fileMetric[backupUrl!]: metricList
            if(outMetricList != nil)
            {
                var metricOutput = "Metrics: "
                for metric in outMetricList!{
                    metricOutput += "\n  - \(metric.metric_type ?? "<TYPE_UNKNOWN>")"
                }
                print("📊 \(metricOutput)")
            }
        }
        
        // Declare local metric/data varaibles
        let metricData: Data?
        var metricListCopy = [Metric]()
        
        // Assigned values depend on whether it's backup-resend or standard push
        if(backupUrl != nil)
        {
            var backupMetricList = TempoDataBackup.fileMetric[backupUrl!]
            metricData = try? JSONEncoder().encode(backupMetricList)
        }
        else {
            metricListCopy = metricList;
            metricData = try? JSONEncoder().encode(metricList)
            metricList.removeAll()
        }

        request.httpBody = metricData // pass dictionary to data object and set it as request body

        //HTTP Headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil else {
                // TODO: add error handling here, maybe try to send again? Or just send a "FAILED_TO_PUSH" single metric elsewhere?
                if(backupUrl == nil) {
                    print("Data did not send, creating backup")
                    TempoDataBackup.sendData(metricsArray: metricListCopy)
                }
                else{
                    print("Data did not send, keeping backup: \(backupUrl!)")
                }
                return
            }
            
            // If metrics were backeups - and were successfully resent - delete the file fro mdevice storage
            if(backupUrl != nil)
            {
                if(TempoConstants.IS_DEBUGGING)
                {
                    print("Removing backup: \(backupUrl!) (x\(TempoDataBackup.fileMetric[backupUrl!]!.count))")
                }
                
                // Remove metricList from device storage
                TempoDataBackup.removeSpecificMetricList(backupUrl: backupUrl!)
            }
            else
            {
                if(TempoConstants.IS_DEBUGGING)
                {
                    print("Standard Metric sent (x\(metricListCopy.count))")
                }
            }
        })
        
        task.resume()
    }
    
    /// Checks once if there are any backed up metrics and runs if found
    public func checkHeldMetrics() {
        // See if check has already been called
        if(TempoDataBackup.readyForCheck) {
            // Request creation of backup metrics dictionary
            TempoDataBackup.initCheck()
            print("Resending: \(TempoDataBackup.fileMetric.count)")
            
            // Cycles through each stored arrays and resends
            for url in TempoDataBackup.fileMetric.keys
            {
                pushMetrics(backupUrl: url)
            }
            
            // Prevents from beign checked again this session. If network is failing, no point retrying during this session
            TempoDataBackup.readyForCheck = false
        }
    }
}
