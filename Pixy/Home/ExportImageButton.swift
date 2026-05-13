import SwiftUI

struct ExportImageButton: View {
    @Environment(PixyVM.self) private var vm
    
    var body: some View {
        if let exportURL = vm.exportURL {
            ShareLink(item: exportURL) {
                Label("Export", systemImage: "square.and.arrow.up")
            }
        } else {
            Button("Export", systemImage: "square.and.arrow.up") {}
                .disabled(true)
        }
    }
}
