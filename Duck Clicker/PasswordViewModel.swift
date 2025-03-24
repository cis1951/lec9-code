import SwiftUI

@Observable class PasswordViewModel {
    static let shared = PasswordViewModel()
    
    private static let passwordKey = "password"
    
    private(set) var isAuthenticated: Bool
    
    private init() {
        self.isAuthenticated = true
    }
    
    func checkPassword(password: String) -> Bool {
        return false
    }
    
    func setPassword(password: String) {
        fatalError("Unimplemented")
    }
}
