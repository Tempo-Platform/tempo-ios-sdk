// General constants in use throughout app

public struct Constants {
    
    public static let IS_PROD = false
    public static let IS_TESTING = true
    
    static let SDK_VERSIONS = "1.1.0"
    static let NO_FILL = "NO_FILL"
    static let OK = "OK"
    static let UNDEF = "UNDEFINED"
    static let ZERO_AD_ID = "00000000-0000-0000-0000-000000000000"
    
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
    
    struct MetricType {
        static let LOAD_REQUEST = "AD_LOAD_REQUEST"
        static let CUST_LOAD_REQUEST = "CUSTOM_AD_LOAD_REQUEST"
        static let SHOW = "AD_SHOW"
        static let LOAD_FAILED = "AD_LOAD_FAILED"
        static let LOAD_SUCCESS = "AD_LOAD_SUCCESS"
        static let CLOSE_AD = "TEMPO_CLOSE_AD"
        static let ASSETS_LOADED = "TEMPO_ASSETS_LOADED"
        static let VIDEO_LOADED = "TEMPO_VIDEO_LOADED"
        static let IMAGES_LOADED = "TEMPO_IMAGES_LOADED"
        static let TIMER_COMPLETED = "TIMER_COMPLETED"
        static let METRIC_OUTPUT_TYPES = [ASSETS_LOADED, VIDEO_LOADED, TIMER_COMPLETED, IMAGES_LOADED]
        static let METRIC_SEND_NOW = [SHOW, LOAD_REQUEST, TIMER_COMPLETED]
    }
    
}
