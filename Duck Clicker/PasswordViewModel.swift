import SwiftUI
import KeychainSwift

class PasswordViewModel: ObservableObject {
    static let shared = PasswordViewModel()
    @Published private(set) var isAuthenticated: Bool
    
    private let keychain: KeychainSwift
    private var password: String?
    
    private init() {
        let keychain = KeychainSwift()
        
        self.keychain = keychain
        self.password = keychain.get("password")
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
        if !keychain.set(password, forKey: "password") {
            print("\(password) NOT WRITTEN TO KEYCHAIN")
        }
    }
}
