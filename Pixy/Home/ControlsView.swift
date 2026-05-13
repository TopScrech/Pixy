import ScrechKit

struct ControlsView: View {
    @Environment(PixyVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        VStack(alignment: .leading, spacing: 16) {
            Text("Customization")
                .title2(.bold)
            
            HStack(spacing: 0) {
                Text("Pixel size")
                    .semibold()
                
                Spacer()
                
                Text(vm.pixelGridLabel)
                    .secondary()
                
                Text(" • ")
                    .secondary()
                
                Text(vm.pixelSizeLabel)
                    .secondary()
                    .monospacedDigit()
            }
            
            Slider(value: $vm.selectedPixelSize, in: 1...100, step: 1)
            
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
