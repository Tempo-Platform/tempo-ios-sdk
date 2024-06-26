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
    case failedToRemoveFiles(Error)
    case checkingFailed(Error)
    case metricResendFailed(URL, Error)
    
    // Backups
    case invalidDirectory
    case contentsOfDirectoryFailed(Error)
    case attributesOfItemFailed(Error)
    case dataReadingFailed(Error)
    case decodingFailed(Error)
}

enum StoreDataError: Error {
    case directoryCreationFailed
    case jsonDataEncodingFailed
    case fileWriteFailed
    case attributesFetchFailed
}

enum LocationDataError: Error {
    case missingBackupData
    case decodingFailed(Error)
}
