import SwiftUI

struct DropZoneActions: View {
    @Environment(PixyVM.self) private var vm
    
    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack {
                ImagePicker()
                
                if vm.hasImage {
                    ClearImageButton()
                }
            }
            
            VStack {
                ImagePicker()
                
                if vm.hasImage {
                    ClearImageButton()
                }
            }
        }
    }
}

#Preview {
    DropZoneActions()
        .environment(PixyVM())
}
