import ScrechKit

struct HeroView: View {
    let vm: PixyVM
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Turn any image into chunky pixel art")
                .largeTitle(.bold)
            
            Text("Drop in a PNG, JPEG, WEBP, or HEIC, tune the block size, and export a crisp pixel version")
                .title3()
                .secondary()
            
            if vm.hasImage {
                ViewThatFits(in: .horizontal) {
                    HStack {
                        Label(vm.sourceDimensionsLabel, systemImage: "photo")
                        Label(vm.pixelSizeLabel, systemImage: "square.grid.3x3.fill")
                        Label(vm.pixelGridLabel, systemImage: "square.split.2x2")
                    }
                    
                    VStack(alignment: .leading) {
                        Label(vm.sourceDimensionsLabel, systemImage: "photo")
                        Label(vm.pixelSizeLabel, systemImage: "square.grid.3x3.fill")
                        Label(vm.pixelGridLabel, systemImage: "square.split.2x2")
                    }
                }
                .headline()
                .padding()
                .background(.regularMaterial, in: .rect(cornerRadius: 28))
            }
        }
    }
}
