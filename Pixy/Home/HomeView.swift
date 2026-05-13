import SwiftUI
import UniformTypeIdentifiers

struct HomeView: View {
    @State private var vm = PixyVM()
    
    var body: some View {
        @Bindable var vm = vm
        
        ScrollView {
            VStack(alignment: .leading) {
                HeroView()
                DropZone()
                
                if vm.hasImage {
                    PreviewCard()
                    ControlsView()
                }
            }
            .frame(maxWidth: 1120)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
        }
        .navigationTitle("Image to Pixel Art")
        .background(HomeViewBackground())
        .environment(vm)
        .fileImporter(isPresented: $vm.isImportingImage, allowedContentTypes: [.image]) {
            vm.handleImportResult($0)
        }
        .alert(item: $vm.importError) { error in
            Alert(
                title: Text("Couldn’t import image"),
                message: Text(error.message)
            )
        }
    }
}
