import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationSplitView {
            List {
                Label("__PROJECT_NAME__", systemImage: "sidebar.left")
            }
            .navigationTitle("__PROJECT_NAME__")
        } detail: {
            VStack(spacing: 16) {
                Image(systemName: "macwindow.badge.plus")
                    .font(.system(size: 42))
                Text("Replace this starter UI with your product surface.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .padding(24)
        }
    }
}

#Preview {
    HomeView()
}
