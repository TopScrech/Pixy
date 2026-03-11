import SwiftUI
import ScrechKit

struct PixelArtControlsView: View {
    @Bindable var vm: PixelArtVM
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Pixel settings")
                .title2(.bold)
            
            Text("Increase the block size for a chunkier result and export the PNG when it looks right")
                .headline()
                .secondary()
            
            VStack(alignment: .leading) {
                LabeledContent("Pixel size") {
                    Text(vm.pixelSizeLabel)
                        .monospacedDigit()
                }
                
                Slider(value: $vm.selectedPixelSize, in: 1...100, step: 1)
                    .disabled(!vm.hasImage)
                
                if vm.hasImage {
                    Text(vm.pixelGridLabel)
                        .headline()
                        .secondary()
                } else {
                    Text("Choose or drop an image to unlock the preview")
                        .headline()
                        .secondary()
                }
            }

            Toggle("Black & White", isOn: $vm.usesTwoColors)
                .disabled(!vm.hasImage)

            Text("Turns every block into pure black or pure white with no gray shades")
                .headline()
                .secondary()

            if vm.hasImage {
                Text(vm.colorModeLabel)
                    .headline()
                    .secondary()
            }
            
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
