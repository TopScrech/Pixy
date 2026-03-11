import SwiftUI
import ScrechKit

struct PixelArtControlsView: View {
    @Bindable var viewModel: PixelArtViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Pixel settings")
                .title2(.bold)
            
            Text("Increase the block size for a chunkier result and export the PNG when it looks right")
                .headline()
                .secondary()
            
            VStack(alignment: .leading) {
                LabeledContent("Pixel size") {
                    Text(viewModel.pixelSizeLabel)
                        .monospacedDigit()
                }
                
                Slider(value: $viewModel.selectedPixelSize, in: 4 ... 60, step: 1)
                    .disabled(!viewModel.hasImage)
                
                if viewModel.hasImage {
                    Text(viewModel.pixelGridLabel)
                        .headline()
                        .secondary()
                } else {
                    Text("Choose or drop an image to unlock the preview")
                        .headline()
                        .secondary()
                }
            }
            
            ViewThatFits(in: .horizontal) {
                HStack {
                    Button("Choose Image", systemImage: "folder") {
                        viewModel.isImportingImage = true
                    }
                    .buttonStyle(.bordered)
                    
                    if let exportURL = viewModel.exportURL {
                        ShareLink(item: exportURL) {
                            Label("Export PNG", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                
                VStack(alignment: .leading) {
                    Button("Choose Image", systemImage: "folder") {
                        viewModel.isImportingImage = true
                    }
                    .buttonStyle(.bordered)
                    
                    if let exportURL = viewModel.exportURL {
                        ShareLink(item: exportURL) {
                            Label("Export PNG", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 32))
    }
}
