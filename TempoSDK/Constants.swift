// General constants in use throughout app

public struct Constants {
    
    public static let IS_PROD = false
    public static let IS_TESTING = true
    
    static let SDK_VERSIONS = "1.1.0"
    static let UNDEF = "UNDEFINED"
    
    struct Backup {
        static let METRIC_BACKUP_FOLDER = "metricJsons"
        static let METRIC_BACKUP_APPEND = ".tempo"
        static let MAX_BACKUPS: Int = 100
        static let EXPIRY_DAYS: Int = 7
    }
    
    struct Web {
        static let METRICS_URL_PROD = "https://metric-api.tempoplatform.com/metrics" // PROD
        static let ADS_API_URL_PROD = "https://ads-api.tempoplatform.com/ad" // PROD
        static let ADS_DOM_URL_PROD = "https://ads.tempoplatform.com" // PROD
        static let METRICS_URL_DEV = "https://metric-api.dev.tempoplatform.com/metrics" // DEV
        static let ADS_API_URL_DEV = "https://ads-api.dev.tempoplatform.com/ad" // DEV
        static let ADS_DOM_URL_DEV = "https://development--tempo-html-ads.netlify.app" // DEV
        static let URL_INT = "interstitial"
        static let URL_REW = "campaign"
        static let METRIC_TIME_HEADER = "X-Timestamp"
    }
    
}
