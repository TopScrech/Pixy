import SwiftUI

struct ImageImportMenu: View {
    @Environment(PixyVM.self) private var vm
    
    let title: LocalizedStringKey
    let icon: String
    
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
    }
}
