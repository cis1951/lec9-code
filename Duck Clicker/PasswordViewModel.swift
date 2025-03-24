import SwiftUI
import KeychainSwift

@Observable class PasswordViewModel {
    static let shared = PasswordViewModel()
    
    private static let passwordKey = "password"
    
    private(set) var isAuthenticated: Bool
    
    private let keychain: KeychainSwift
    private var password: String?
    
    private init() {
        let keychain = KeychainSwift()
        let password = keychain.get(Self.passwordKey)
        
        self.keychain = keychain
        self.password = password
        self.isAuthenticated = password == nil
    }
    
    func checkPassword(password: String) -> Bool {
        if password == self.password {
            isAuthenticated = true
            return true
        }
        
        return false
    }
    
    func setPassword(password: String) {
        self.password = password
        precondition(keychain.set(password, forKey: Self.passwordKey), "Failed to write password to keychain")
    }
}
