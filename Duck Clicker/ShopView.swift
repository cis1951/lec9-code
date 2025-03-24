import SwiftUI
import SwiftData

struct ShopView: View {
    @Binding var clicks: Int
    @Query(sort: \ShopItem.price) var shopItems: [ShopItem]
    
    var body: some View {
        List(shopItems) { item in
            Button {
                item.amountPurchased += 1
                clicks -= item.price
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.name)
                        Text("Price: ^[\(item.price) clicks](inflect: true)")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("x\(item.amountPurchased)")
                }
            }
            .disabled(clicks < item.price)
            .tint(.primary)
        }
        .navigationTitle("Shop")
    }
}

#Preview {
    ShopView(clicks: .constant(0))
        .modelContainer(for: [ShopItem.self])
}
