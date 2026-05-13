import SwiftUI

struct ImagePicker: View {
    @Environment(PixyVM.self) private var vm
    
    var body: some View {
        ImageImportMenu(icon: "folder")
            .buttonStyle(.borderedProminent)
    }
}

//#Preview {
//    ImagePicker()
//}
