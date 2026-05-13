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
                    .monospacedDigit()
            }
            
            Picker("Color mode", selection: $vm.colorMode) {
                ForEach(PixelColorMode.allCases) {
                    Text($0.title)
                        .tag($0)
                }
            }
            .pickerStyle(.segmented)
            
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 32))
    }
}
