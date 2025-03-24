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
