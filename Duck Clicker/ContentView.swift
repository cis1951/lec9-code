import SwiftUI

struct ContentView: View {
    @EnvironmentObject var passwordViewModel: PasswordViewModel
    
    @State var pendingPassword = ""
    @State var isWrongPassword = false
    
    var body: some View {
        if passwordViewModel.isAuthenticated {
            GameView()
        } else {
            VStack {
                Text("Enter your password to access Duck Clicker")
                if isWrongPassword {
                    Text("Incorrect password")
                        .foregroundStyle(.red)
                }
                SecureField("Password", text: $pendingPassword)
                    .textFieldStyle(.roundedBorder)
                Button("Authenticate") {
                    if !passwordViewModel.checkPassword(password: pendingPassword) {
                        isWrongPassword = true
                    }
                }
                .buttonStyle(BorderedProminentButtonStyle())
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ShopViewModel.shared)
        .environmentObject(PasswordViewModel.shared)
}
