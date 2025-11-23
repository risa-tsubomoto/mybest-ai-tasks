import Foundation
import Security

/// キーチェーンへのデータ保存・読み出しを行うヘルパークラス。
public class KeychainHelper {
    /// シングルトンインスタンス。
    public static let shared = KeychainHelper()
    
    private init() {}
    
    /// キーチェーンにデータを保存する。
    /// - Parameters:
    ///   - value: 保存する文字列データ。
    ///   - key: データを識別するキー。
    public func save(_ value: String, for key: String) {
        let data = Data(value.utf8)
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data
        ] as [String: Any]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    /// キーチェーンからデータを読み出す。
    /// - Parameter key: データを識別するキー。
    /// - Returns: 保存された文字列データ。存在しない場合は nil。
    public func read(for key: String) -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as [String: Any]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        
        return nil
    }
    
    /// キーチェーンからデータを削除する。
    /// - Parameter key: データを識別するキー。
    public func delete(for key: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ] as [String: Any]
        
        SecItemDelete(query as CFDictionary)
    }
}
