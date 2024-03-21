import SwiftUI

class PasswordViewModel: ObservableObject {
    static let shared = PasswordViewModel()
    @Published private(set) var isAuthenticated: Bool

    private init() {
        self.isAuthenticated = true
    }
    
    func checkPassword(password: String) -> Bool {
        return false
    }
    
    func setPassword(password: String) {
        
    }
}
