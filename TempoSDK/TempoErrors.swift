//
//  TempoErrors.swift
//  TempoSDK
//
//  Created by Stephen Baker on 26/6/2024.
//

import Foundation

enum CountryCodeError: Error {
    case unknownError
    case missingCountryCode
    case missingCurrencyCode
    case missingRegionLocale
}

enum MetricsError: Error {
    case unknownError
    case invalidURL
    case jsonEncodingFailed
    case missingJsonString
    case emptyMetrics
    case networkError(Error)
    case invalidHeaderValue
}
