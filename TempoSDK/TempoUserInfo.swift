
import Foundation


public class TempoUserInfo {
    
    static let currentLocale = Locale.current
    static let unknown = "???"
    
    /// Test  blueprint/ouput for any future requests
    public static func printOtherDetails() {
        
        let currencyCode = currentLocale.currencyCode
        let regionLocale = currentLocale.identifier
        let countryCode: String?
        
        if #available(iOS 16, *) {
            countryCode = currentLocale.language.region?.identifier
        } else {
            countryCode = currentLocale.regionCode
        }
        print("🌏 Location details:\n - Currency Code: \(currencyCode!)\n - Region Locale: \(regionLocale)\n - Country Code: \(countryCode ?? "NIL")")
    }
    
    /// Returns the ISO/countryCode as per the user's device region settings ISO 3166-1 (alpha-2)
    public static func getIsoCountryCode2Digit() -> String?
    {
        var currencyCode: String?
        
        // currentLocale.regionCode deprecated in iOS 16
        if #available(iOS 16, *) {
            currencyCode = currentLocale.language.region?.identifier
        } else {
            currencyCode = currentLocale.regionCode
        }

        if(currencyCode == nil)
        {
            currencyCode = iso1366Dict[getIsoCountryCode3Digit()]
        }
        
        return currencyCode;
    }
    
    /// Returns the ISO/countryCode as per the user's device region settings ISO 3166-1 (alpha-3)
    public static func getIsoCountryCode3Digit() -> String
    {
//        let currencyCode = currentLocale.currencyCode
//        if(currencyCode == nil || currencyCode == "") {
//            print("3 digit country code not recognised, return \(unknown)")
//            return unknown // Technically, Locale.current.currencyCode defaults to "XXX" so this should never happen
//        }
//        else {
//            return currencyCode!
//        }
        
        return "???"
    }
    
    // Dictionary of 3 -> 2 digit ISO-1366-1 counrty codes
    // Source: https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes
    static let iso1366Dict: [String: String] = [
        "ABW": "AW",
        "AFG": "AF",
        "AGO": "AO",
        "AIA": "AI",
        "ALA": "AX",
        "ALB": "AL",
        "AND": "AD",
        "ARE": "AE",
        "ARG": "AR",
        "ARM": "AM",
        "ASM": "AS",
        "ATA": "AQ",
        "ATF": "TF",
        "ATG": "AG",
        "AUS": "AU",
        "AUT": "AT",
        "AZE": "AZ",
        "BDI": "BI",
        "BEL": "BE",
        "BEN": "BJ",
        "BES": "BQ",
        "BFA": "BF",
        "BGD": "BD",
        "BGR": "BG",
        "BHR": "BH",
        "BHS": "BS",
        "BIH": "BA",
        "BLM": "BL",
        "BLR": "BY",
        "BLZ": "BZ",
        "BMU": "BM",
        "BOL": "BO",
        "BRA": "BR",
        "BRB": "BB",
        "BRN": "BN",
        "BTN": "BT",
        "BVT": "BV",
        "BWA": "BW",
        "CAF": "CF",
        "CAN": "CA",
        "CCK": "CC",
        "CHE": "CH",
        "CHL": "CL",
        "CHN": "CN",
        "CIV": "CI",
        "CMR": "CM",
        "COD": "CD",
        "COG": "CG",
        "COK": "CK",
        "COL": "CO",
        "COM": "KM",
        "CPV": "CV",
        "CRI": "CR",
        "CUB": "CU",
        "CUW": "CW",
        "CXR": "CX",
        "CYM": "KY",
        "CYP": "CY",
        "CZE": "CZ",
        "DEU": "DE",
        "DJI": "DJ",
        "DMA": "DM",
        "DNK": "DK",
        "DOM": "DO",
        "DZA": "DZ",
        "ECU": "EC",
        "EGY": "EG",
        "ERI": "ER",
        "ESH": "EH",
        "ESP": "ES",
        "EST": "EE",
        "ETH": "ET",
        "FIN": "FI",
        "FJI": "FJ",
        "FLK": "FK",
        "FRA": "FR",
        "FRO": "FO",
        "FSM": "FM",
        "GAB": "GA",
        "GBR": "GB",
        "GEO": "GE",
        "GGY": "GG",
        "GHA": "GH",
        "GIB": "GI",
        "GIN": "GN",
        "GLP": "GP",
        "GMB": "GM",
        "GNB": "GW",
        "GNQ": "GQ",
        "GRC": "GR",
        "GRD": "GD",
        "GRL": "GL",
        "GTM": "GT",
        "GUF": "GF",
        "GUM": "GU",
        "GUY": "GY",
        "HKG": "HK",
        "HMD": "HM",
        "HND": "HN",
        "HRV": "HR",
        "HTI": "HT",
        "HUN": "HU",
        "IDN": "ID",
        "IMN": "IM",
        "IND": "IN",
        "IOT": "IO",
        "IRL": "IE",
        "IRN": "IR",
        "IRQ": "IQ",
        "ISL": "IS",
        "ISR": "IL",
        "ITA": "IT",
        "JAM": "JM",
        "JEY": "JE",
        "JOR": "JO",
        "JPN": "JP",
        "KAZ": "KZ",
        "KEN": "KE",
        "KGZ": "KG",
        "KHM": "KH",
        "KIR": "KI",
        "KNA": "KN",
        "KOR": "KR",
        "KWT": "KW",
        "LAO": "LA",
        "LBN": "LB",
        "LBR": "LR",
        "LBY": "LY",
        "LCA": "LC",
        "LIE": "LI",
        "LKA": "LK",
        "LSO": "LS",
        "LTU": "LT",
        "LUX": "LU",
        "LVA": "LV",
        "MAC": "MO",
        "MAF": "MF",
        "MAR": "MA",
        "MCO": "MC",
        "MDA": "MD",
        "MDG": "MG",
        "MDV": "MV",
        "MEX": "MX",
        "MHL": "MH",
        "MKD": "MK",
        "MLI": "ML",
        "MLT": "MT",
        "MMR": "MM",
        "MNE": "ME",
        "MNG": "MN",
        "MNP": "MP",
        "MOZ": "MZ",
        "MRT": "MR",
        "MSR": "MS",
        "MTQ": "MQ",
        "MUS": "MU",
        "MWI": "MW",
        "MYS": "MY",
        "MYT": "YT",
        "NAM": "NA",
        "NCL": "NC",
        "NER": "NE",
        "NFK": "NF",
        "NGA": "NG",
        "NIC": "NI",
        "NIU": "NU",
        "NLD": "NL",
        "NOR": "NO",
        "NPL": "NP",
        "NRU": "NR",
        "NZL": "NZ",
        "OMN": "OM",
        "PAK": "PK",
        "PAN": "PA",
        "PCN": "PN",
        "PER": "PE",
        "PHL": "PH",
        "PLW": "PW",
        "PNG": "PG",
        "POL": "PL",
        "PRI": "PR",
        "PRK": "KP",
        "PRT": "PT",
        "PRY": "PY",
        "PSE": "PS",
        "PYF": "PF",
        "QAT": "QA",
        "REU": "RE",
        "ROU": "RO",
        "RUS": "RU",
        "RWA": "RW",
        "SAU": "SA",
        "SDN": "SD",
        "SEN": "SN",
        "SGP": "SG",
        "SGS": "GS",
        "SHN": "SH",
        "SJM": "SJ",
        "SLB": "SB",
        "SLE": "SL",
        "SLV": "SV",
        "SMR": "SM",
        "SOM": "SO",
        "SPM": "PM",
        "SRB": "RS",
        "SSD": "SS",
        "STP": "ST",
        "SUR": "SR",
        "SVK": "SK",
        "SVN": "SI",
        "SWE": "SE",
        "SWZ": "SZ",
        "SXM": "SX",
        "SYC": "SC",
        "SYR": "SY",
        "TCA": "TC",
        "TCD": "TD",
        "TGO": "TG",
        "THA": "TH",
        "TJK": "TJ",
        "TKL": "TK",
        "TKM": "TM",
        "TLS": "TL",
        "TON": "TO",
        "TTO": "TT",
        "TUN": "TN",
        "TUR": "TR",
        "TUV": "TV",
        "TWN": "TW",
        "TZA": "TZ",
        "UGA": "UG",
        "UKR": "UA",
        "UMI": "UM",
        "URY": "UY",
        "USA": "US",
        "UZB": "UZ",
        "VAT": "VA",
        "VCT": "VC",
        "VEN": "VE",
        "VGB": "VG",
        "VIR": "VI",
        "VNM": "VN",
        "VUT": "VU",
        "WLF": "WF",
        "WSM": "WS",
        "YEM": "YE",
        "ZAF": "ZA",
        "ZMB": "ZM",
        "ZWE": "ZW"
    ]
    
}


