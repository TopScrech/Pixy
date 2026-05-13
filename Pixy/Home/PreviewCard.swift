import ScrechKit

struct PreviewCard: View {
    @Environment(PixyVM.self) private var vm
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Pixelized")
                .title3(.bold)
            
            Text(vm.pixelGridLabel)
                .headline()
                .secondary()
            
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(.white.opacity(0.78))
                
                if let image = vm.pixelizedImage {
                    Image(decorative: image, scale: 1)
                        .interpolation(.none)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                    
                } else if vm.isRenderingPixelArt {
                    ProgressView("Rendering pixel art")
                    
                } else {
                    ContentUnavailableView(
                        "No Preview Yet",
                        systemImage: "sparkles.rectangle.stack",
                        description: Text("Import an image to see the pixelized version")
                    )
                    .padding()
                }
            }
            .frame(maxWidth: .infinity, minHeight: 320)
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 32))
    }
}
