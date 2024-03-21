import SwiftUI
import CoreData

struct ShopView: View {
    @Binding var clicks: Int
    @FetchRequest(sortDescriptors: []) var shopItems: FetchedResults<ShopItem>
    @EnvironmentObject var shopViewModel: ShopViewModel
    
    var body: some View {
        List(shopItems, id: \.id) { item in
            Button {
                item.quantity += 1
                clicks -= Int(item.price)
                shopViewModel.save()
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.name ?? "Unknown Item")
                        Text("Price: ^[\(item.price) clicks](inflect: true)")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("x\(item.quantity)")
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
        .environmentObject(ShopViewModel.shared)
}
