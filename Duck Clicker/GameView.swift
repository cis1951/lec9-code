import SwiftUI

struct GameView: View {
    @AppStorage("clicks") var clicks = 0
    
    @FetchRequest(sortDescriptors: []) var shopItems: FetchedResults<ShopItem>
    @State var isSettingPassword = false
    @State var pendingPassword = ""
    @EnvironmentObject var passwordViewModel: PasswordViewModel
    
    var clicksPerSecond: Int {
        var clicks = 0
        for item in shopItems {
            clicks += Int(item.clicksPerSecond * item.quantity)
        }
        return clicks
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("^[\(clicks) clicks](inflect: true)")
                    .font(.title)
                    .fontWeight(.bold)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: clicks)
                Text("^[\(clicksPerSecond) clicks](inflect: true)/sec")
                Button {
                    clicks += 1
                } label: {
                    Image("Duck")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipShape(.rect(cornerRadius: 32))
                }
            }
            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                clicks += clicksPerSecond
            }
            .navigationTitle("Duck Clicker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    NavigationLink {
                        ShopView(clicks: $clicks)
                    } label: {
                        Label("Shop", systemImage: "bag")
                    }
                }
                
                ToolbarItem {
                    Button {
                        pendingPassword = ""
                        isSettingPassword = true
                    } label: {
                        Label("Set Password", systemImage: "key")
                    }
                }
            }
            .alert("Set password", isPresented: $isSettingPassword) {
                SecureField("Password", text: $pendingPassword)
                Button("Cancel", role: .cancel) {
                    isSettingPassword = false
                }
                Button("Set") {
                    passwordViewModel.setPassword(password: pendingPassword)
                    isSettingPassword = false
                }
            }
        }
    }
}

#Preview {
    GameView()
        .environmentObject(ShopViewModel.shared)
        .environmentObject(PasswordViewModel.shared)
}
