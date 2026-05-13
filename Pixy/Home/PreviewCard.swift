import ScrechKit

struct PreviewCard: View {
    @Environment(PixyVM.self) private var vm
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Pixelized")
                .title3(.bold)
            
            Label("\(vm.sourceDimensionsLabel)", systemImage: "photo")
                .headline()
                .secondary()
            
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(.clear)
                
                if let image = vm.pixelizedImage {
                    Image(decorative: image, scale: 1)
                        .interpolation(.none)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(.rect(cornerRadius: 28))
                    
                } else if vm.isRenderingPixelArt {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.white.opacity(0.78))
                    
                    ProgressView("Rendering pixel art")
                    
                } else {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.white.opacity(0.78))
                    
                    ContentUnavailableView(
                        "No Preview Yet",
                        systemImage: "sparkles.rectangle.stack",
                        description: Text("Import an image to see the pixelized version")
                    )
                    .padding()
                }
            }
            .aspectRatio(vm.sourceAspectRatio, contentMode: .fit)
            .frame(maxWidth: .infinity, minHeight: 320)
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 32))
    }
}
