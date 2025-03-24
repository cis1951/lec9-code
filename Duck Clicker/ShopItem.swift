import Foundation
import SwiftData

@Model
class ShopItem {
    @Attribute(.unique) var name: String
    var price: Int
    var clicksPerSecond: Int
    
    var amountPurchased: Int
    
    init(name: String, price: Int, clicksPerSecond: Int) {
        self.name = name
        self.price = price
        self.amountPurchased = 0
        self.clicksPerSecond = clicksPerSecond
    }
}

extension ModelContext {
    func createShopItem(name: String, price: Int, clicksPerSecond: Int) throws {
        let descriptor = FetchDescriptor<ShopItem>(
            predicate: #Predicate { $0.name == name }
        )
        
        let existingItems = try fetch(descriptor)
        guard existingItems.isEmpty else {
            return
        }
        
        let item = ShopItem(name: name, price: price, clicksPerSecond: clicksPerSecond)
        insert(item)
    }
    
    func createInitialShopItems() throws {
        
    }
}
