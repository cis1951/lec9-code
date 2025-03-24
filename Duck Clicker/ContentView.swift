import SwiftUI

struct ContentView: View {
    @State var pendingPassword = ""
    @State var isWrongPassword = false
    
    var body: some View {
        if PasswordViewModel.shared.isAuthenticated {
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
                    if !PasswordViewModel.shared.checkPassword(password: pendingPassword) {
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
}
