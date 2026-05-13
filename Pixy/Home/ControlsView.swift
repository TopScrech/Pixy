import ScrechKit

struct ControlsView: View {
    @Environment(PixyVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        VStack(alignment: .leading) {
            Text("Pixel settings")
                .title2(.bold)
            
            VStack(alignment: .leading) {
                LabeledContent("Pixel size") {
                    Text(vm.pixelSizeLabel)
                        .monospacedDigit()
                }
                
                Slider(value: $vm.selectedPixelSize, in: 1...100, step: 1)
                
                Text(vm.pixelGridLabel)
                    .headline()
                    .secondary()
            }
            
            Toggle("Black & White", isOn: $vm.usesTwoColors)
            
            if let exportURL = vm.exportURL {
                ShareLink(item: exportURL) {
                    Label("Export PNG", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 32))
    }
}
