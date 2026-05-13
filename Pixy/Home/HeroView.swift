import ScrechKit

struct HeroView: View {
    @Environment(PixyVM.self) private var vm
    
    var body: some View {
        VStack(alignment: .leading) {
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
