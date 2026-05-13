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
                    PreviewCard(
                        title: "Pixelized",
                        subtitle: vm.pixelGridLabel,
                        image: vm.pixelizedImage,
                        isLoading: vm.isRenderingPixelArt
                    )
                }
                
                ControlsView(vm: vm)
            }
            .frame(maxWidth: 1120)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
        }
        .background {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.95, blue: 0.90),
                        Color(red: 0.93, green: 0.87, blue: 0.78)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                Circle()
                    .fill(.orange.opacity(0.18))
                    .frame(width: 320)
                    .blur(radius: 30)
                    .offset(x: -180, y: -260)
                
                Circle()
                    .fill(.red.opacity(0.12))
                    .frame(width: 280)
                    .blur(radius: 40)
                    .offset(x: 240, y: 320)
            }
            .ignoresSafeArea()
        }
        .navigationTitle("Image to Pixel Art")
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
