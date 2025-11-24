import Foundation
import Dependencies
import DependenciesMacros
import os.log

/// ログ出力を担当するクライアント
@DependencyClient
public struct LoggerClient: Sendable {
    /// 情報レベルのログを出力 (OSLogType: .info)
    public var info: @Sendable (_ message: String) -> Void
    
    /// エラーレベルのログを出力 (OSLogType: .error)
    public var error: @Sendable (_ message: String) -> Void
    
    /// デバッグレベルのログを出力 (OSLogType: .debug)
    public var debug: @Sendable (_ message: String) -> Void
    
    /// 警告レベルのログを出力 (OSLogType: .default)
    public var warning: @Sendable (_ message: String) -> Void
}

extension LoggerClient: DependencyKey {
    public static let liveValue: LoggerClient = {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "GoalCrusher", category: "App")
        
        return LoggerClient(
            info: { message in
                logger.info("\(message)")
            },
            error: { message in
                logger.error("\(message)")
            },
            debug: { message in
                logger.debug("\(message)")
            },
            warning: { message in
                logger.warning("\(message)")
            }
        )
    }()
}

public extension DependencyValues {
    var logger: LoggerClient {
        get { self[LoggerClient.self] }
        set { self[LoggerClient.self] = newValue }
    }
}
