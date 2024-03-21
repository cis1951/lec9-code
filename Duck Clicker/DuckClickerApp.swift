import SwiftUI
import CoreData

@main
struct DuckClickerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ShopViewModel.shared)
                .environmentObject(PasswordViewModel.shared)
        }
    }
}
