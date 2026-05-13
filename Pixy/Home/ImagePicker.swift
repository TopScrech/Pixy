import SwiftUI

struct ImagePicker: View {
    @Environment(PixyVM.self) private var vm
    
    private var title: LocalizedStringKey {
        vm.hasImage ? "Replace Image" : "Choose Image"
    }
    
    private var icon: String {
        vm.hasImage ? "arrow.trianglehead.2.clockwise.rotate.90" : "folder"
    }
    
    var body: some View {
        Button(title, systemImage: icon) {
            vm.isImportingImage = true
        }
        .buttonStyle(.borderedProminent)
    }
}

//#Preview {
//    ImagePicker()
//}
