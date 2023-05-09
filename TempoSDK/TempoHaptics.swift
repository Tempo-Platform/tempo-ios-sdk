//
//  TempoHaptics.swift
//  TempoSDK
//
//  Created by Stephen Baker on 9/5/2023.
//

import Foundation
import UIKit
import CoreHaptics
import AudioToolbox


public class TempoHaptics {
    
    // Standard set effects
    let generatorNotification: UINotificationFeedbackGenerator
    let generatorSelection: UISelectionFeedbackGenerator
    
    // Adjustable impacts
    let generatorLight: UIImpactFeedbackGenerator
    let generatorMedium: UIImpactFeedbackGenerator
    let generatorHeavy: UIImpactFeedbackGenerator
    var generatorSoft: UIImpactFeedbackGenerator?
    var generatorRigid: UIImpactFeedbackGenerator?
    
    // Web reference array
    var refList: [String] = ["TEMPO_HAPTIC_VIBRATE","TEMPO_HAPTIC_SELECTION","TEMPO_HAPTIC_SUCCESS","TEMPO_HAPTIC_ERROR","TEMPO_HAPTIC_WARNING","TEMPO_HAPTIC_LIGHT","TEMPO_HAPTIC_MEDIUM","TEMPO_HAPTIC_HEAVY","TEMPO_HAPTIC_SOFT","TEMPO_HAPTIC_RIGID"]

    public init() {
        print("📳 TempoHaptics initialised")
        
        // Define standard generators
        generatorNotification = UINotificationFeedbackGenerator()
        generatorSelection = UISelectionFeedbackGenerator()
        
        // Define impact feedback generator
        generatorLight = UIImpactFeedbackGenerator(style: .light)
        generatorMedium = UIImpactFeedbackGenerator(style: .medium)
        generatorHeavy = UIImpactFeedbackGenerator(style: .heavy)
        
        if #available(iOS 13.0, *) {
            generatorSoft = UIImpactFeedbackGenerator(style: .soft)
            generatorRigid = UIImpactFeedbackGenerator(style: .rigid)
        }
        
        // Prepare the generator so there is no latency when called
        generatorNotification.prepare()
        generatorSelection.prepare()
        generatorLight.prepare()
        generatorMedium.prepare()
        generatorHeavy.prepare()
        
        if #available(iOS 13.0, *) {
            generatorSoft!.prepare()
            generatorRigid!.prepare()
        }
    }
    
    public func doVibrate() {
        AudioServicesPlayAlertSoundWithCompletion(kSystemSoundID_Vibrate, nil);
        print("📳 Vibrating")
    }
    
    public func doNotificationSuccess() {
        generatorNotification.notificationOccurred(.success)
        print("📳 Success notification")
    }
    
    public func doNotificationWarning() {
        generatorNotification.notificationOccurred(.warning)
        print("📳 Warning notification")
    }
    
    public func doNotificationError() {
        generatorNotification.notificationOccurred(.error)
        print("📳 Error notification")
    }
    
    public func doSelection() {
        generatorSelection.selectionChanged()
        print("📳 Selection")
    }
    
    public func doImpactLight(intensityLevel: CGFloat) {
        var featureAvailable = false
        if #available(iOS 13.0, *) {
            generatorLight.impactOccurred(intensity: intensityLevel)
            featureAvailable = true
        } else {
            generatorLight.impactOccurred()
        }
        print("📳 Light impact: \(featureAvailable ? intensityLevel: 1.0)")
    }
    
    public func doImpactMedium(intensityLevel: CGFloat) {
        var featureAvailable = false
        if #available(iOS 13.0, *) {
            generatorMedium.impactOccurred(intensity: intensityLevel)
            featureAvailable = true
        } else {
            generatorMedium.impactOccurred()
        }
        print("📳 Medium impact: \(featureAvailable ? intensityLevel: 1.0)")
    }
    
    public func doImpactHeavy(intensityLevel: CGFloat) {
        var featureAvailable = false
        if #available(iOS 13.0, *) {
            generatorHeavy.impactOccurred(intensity: intensityLevel)
            featureAvailable = true
        } else {
            generatorHeavy.impactOccurred()
        }
        print("📳 Heavy impact: \(featureAvailable ? intensityLevel: 1.0)")
    }
    
    public func doImpactSoft(intensityLevel: CGFloat) {
        if #available(iOS 13.0, *) {
            generatorSoft!.impactOccurred(intensity: intensityLevel)
            print("📳 Soft impact: \(intensityLevel)")
        } else {
            print("📳 Soft impact not available on this devices! Performing medium impact")
            generatorMedium.impactOccurred()
        }
    }
    
    public func doImpactRigid(intensityLevel: CGFloat) {
            if #available(iOS 13.0, *) {
                generatorRigid!.impactOccurred(intensity: intensityLevel)
                print("📳 Rigid impact: \(intensityLevel)")
            } else {
                print("📳 Rigid impact not available on this devices! Performing medium impact")
                generatorMedium.impactOccurred()
            }
    }
    
    public func hapticSwitch(hapticType: String, intensity: Float) {
        switch(hapticType) {
        case "TEMPO_HAPTIC_VIBRATE": doVibrate(); break;
        case "TEMPO_HAPTIC_SELECTION": doSelection(); break;
        case "TEMPO_HAPTIC_SUCCESS": doNotificationSuccess() ;break;
        case "TEMPO_HAPTIC_ERROR" : doNotificationError(); break;
        case "TEMPO_HAPTIC_WARNING": doNotificationWarning(); break;
        case "TEMPO_HAPTIC_LIGHT": doImpactLight(intensityLevel: CGFloat(intensity)); break;
        case "TEMPO_HAPTIC_MEDIUM": doImpactMedium(intensityLevel: CGFloat(intensity)); break;
        case "TEMPO_HAPTIC_HEAVY": doImpactHeavy(intensityLevel: CGFloat(intensity)); break;
        case "TEMPO_HAPTIC_SOFT": doImpactSoft(intensityLevel: CGFloat(intensity)); break;
        case "TEMPO_HAPTIC_RIGID": doImpactRigid(intensityLevel: CGFloat(intensity)); break;
        default: break;
        }
    }
    
    /*
     var message = {  name: "<stringValue>",  intensity: <floatvalue>  }; // Between 0-1
     window.webkit.messageHandlers.observer.postMessage(message);
     */
}
