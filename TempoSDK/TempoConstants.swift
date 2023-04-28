// General constants in use throughout app

struct TempoConstants {
    static let METRIC_SERVER_URL = "https://metric-api.tempoplatform.com/metrics"
    static let ADS_API = "https://ads-api.tempoplatform.com/ad"
    static let METRIC_BACKUP_FOLDER = "metricJsons"
    static let METRIC_BACKUP_APPEND = ".tempo"
    static let IS_DEBUGGING = false
    static let SDK_VERSIONS = "1.0.1"
    static let METRIC_TIME_HEADER = "X-Timestamp"
    static let MAX_BACKUPS: Int = 100
    static let EXPIRY_DAYS: Int = 7
}
