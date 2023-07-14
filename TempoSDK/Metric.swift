//
//  Metric.swift
//  TempoSDK
//
//  Created by Stephen Baker on 14/7/2023.
//

import Foundation

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
    var sdk_version: String
    var adapter_version: String
    var cpm: Float
    var adapter_type: String?
    var consent: Bool?
    var consent_type: String?
}
