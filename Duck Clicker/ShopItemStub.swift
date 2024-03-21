import CoreData

class ShopItem: Identifiable {
    var id: String? {
        name
    }
    
    var name: String? = ""
    var quantity: Int64 = 0
    var clicksPerSecond: Int64 = 0
    var price: Int64 = 0
}
