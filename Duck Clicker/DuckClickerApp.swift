import SwiftUI
import CoreData

@main
struct DuckClickerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, ShopViewModel.shared.persistentContainer.viewContext)
                .environmentObject(ShopViewModel.shared)
                .environmentObject(PasswordViewModel.shared)
                .onAppear {
                    ShopViewModel.shared.createInitialShopItems()
                }
        }
    }
}
