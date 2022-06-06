import Foundation
import UIKit

public class TempoInterstitial: NSObject {
    private var interstitial:TempoInterstitialView?
    private var parentViewController:UIViewController?
    public init(parentViewController:UIViewController?, delegate:TempoInterstitialDelegate){
        super.init()
        self.parentViewController = parentViewController
        interstitial = TempoInterstitialView()
        interstitial!.delegate = delegate
        interstitial!.loadURLInterstitial(interstitial:self)
    }
    
    public func display(){
        if(interstitial != nil){
            if(parentViewController != nil){
                interstitial!.display(parentViewController!)
            }else{
                // error
            }
        }
    }
}
