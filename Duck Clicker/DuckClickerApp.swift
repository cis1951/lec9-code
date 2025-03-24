import SwiftUI
import SwiftData

@main
struct DuckClickerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [ShopItem.self]) { result in
                    let container = try! result.get()
                    try! container.mainContext.createInitialShopItems()
                }
        }
    }
}
