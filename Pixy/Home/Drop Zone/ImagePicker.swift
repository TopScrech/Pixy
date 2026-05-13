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
        Menu {
#if os(iOS)
            Button("Camera", systemImage: "camera") {
                vm.isTakingPhoto = true
            }
            .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
#endif
            
            Button("Photo Library", systemImage: "photo.on.rectangle") {
                vm.isPickingPhoto = true
            }
            
            Button("Files", systemImage: "folder") {
                vm.isImportingImage = true
            }
        } label: {
            Label(title, systemImage: icon)
        }
        .buttonStyle(.borderedProminent)
    }
}

//#Preview {
//    ImagePicker()
//}
