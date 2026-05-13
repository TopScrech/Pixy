import SwiftUI

struct ClearImageButton: View {
    @Environment(PixyVM.self) private var vm
    
    var body: some View {
        Button("Clear", systemImage: "trash", role: .destructive, action: vm.clearImage)
            .buttonStyle(.bordered)
            .labelStyle(.iconOnly)
            .buttonBorderShape(.circle)
    }
}

#Preview {
    ClearImageButton()
        .environment(PixyVM())
}
