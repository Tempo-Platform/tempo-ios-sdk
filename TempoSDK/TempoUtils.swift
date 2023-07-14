
import Foundation

/**
 * Global tools to use within the Tempo SDK module
 */
public class TempoUtils {
    
    /**
     * Log for URGENT output with 💥 marker - not to be used in production
     */
    public static func Shout(msg: String) {
        if(Constants.IS_TESTING) {
            print("💥 TempoSDK: \(msg)");
        }
    }

    /**
     * Log for URGENT output with 💥 marker, even when TESTING is on - not to be used in production
     */
    public static func Shout(msg: String, absoluteDisplay: Bool) {
        if (absoluteDisplay) {
            print("💥 TempoSDK: \(msg)");
        } else if (Constants.IS_TESTING) {
            // Nothing - muted
        }
    }

    /**
     * Log for general test  output -, never shows in production
     */
    public static func Say(msg: String) {
        if(Constants.IS_TESTING) {
            print("TempoSDK: \(msg)");
        }
    }

    /**
     * Log for general output with - option of toggling production output or off completely
     */
    public static func Say(msg: String, absoluteDisplay: Bool) {
        if (absoluteDisplay) {
            print("TempoSDK: \(msg)");
        } else if (Constants.IS_TESTING) {
            // Nothing - muted
        }
    }

    /**
     * Log for WARNING output with 💥 marker - not to be used in production
     */
    public static func Warn(msg: String) {
        if(Constants.IS_TESTING) {
            print("⚠️ TempoSDK: \(msg)");
        }
    }

    /**
     * Log for WARNING output with 💥 marker, option of toggling production output or off completely
     */
    public static func Warn(msg: String, absoluteDisplay: Bool) {
        if (absoluteDisplay) {
            print("⚠️ TempoSDK: \(msg)");
        } else if (Constants.IS_TESTING) {
            // Nothing - muted
        }
    }
}
