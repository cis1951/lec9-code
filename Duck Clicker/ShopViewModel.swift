import SwiftUI
import CoreData

class ShopViewModel: ObservableObject {
    static let shared = ShopViewModel()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        
        container.loadPersistentStores { stores, error in
            if let error {
                fatalError("Oh no! \(error.localizedDescription)")
            }
        }
        
        return container
    }()
    
    func createShopItem(name: String, price: Int, clicksPerSecond: Int) throws {
        let request = ShopItem.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        
        let results = try persistentContainer.viewContext.fetch(request)
        guard results.isEmpty else { return }
        
        let item = ShopItem(context: persistentContainer.viewContext)
        item.name = name
        item.price = Int64(price)
        item.clicksPerSecond = Int64(clicksPerSecond)
    }
    
    func createInitialShopItems() {
        do {
            try createShopItem(name: "Cursor", price: 1, clicksPerSecond: 1)
            try createShopItem(name: "Test Item", price: 2, clicksPerSecond: 200)
            
            save()
        } catch {
            print("Couldn't create shop items: \(error)")
        }
    }
    
    func save() {
        guard persistentContainer.viewContext.hasChanges else { return }
        
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("Couldn't save: \(error)")
        }
    }
    
    private init() {}
}
