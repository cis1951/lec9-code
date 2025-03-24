import Foundation
import SwiftData

class ShopItem {
    // TODO: Remove, as SwiftData defines its own persistent ID
    let id = UUID()
    
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

extension ShopItem: Identifiable {}

extension ModelContext {
    func createShopItem(name: String, price: Int, clicksPerSecond: Int) throws {
        fatalError("Unimplemented")
    }
    
    func createInitialShopItems() throws {
        try createShopItem(name: "Cursor", price: 1, clicksPerSecond: 1)
        try createShopItem(name: "Test Item", price: 2, clicksPerSecond: 100)
    }
}
