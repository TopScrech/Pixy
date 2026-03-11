import SwiftUI
import ScrechKit

struct PixelArtHeroView: View {
    let viewModel: PixelArtViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Turn any image into chunky pixel art")
                .largeTitle(.bold)
            
            Text("Drop in a PNG, JPEG, WEBP, or HEIC, tune the block size, and export a crisp pixel version")
                .title3()
                .secondary()
            
            if viewModel.hasImage {
                ViewThatFits(in: .horizontal) {
                    HStack {
                        Label(viewModel.sourceDimensionsLabel, systemImage: "photo")
                        Label(viewModel.pixelSizeLabel, systemImage: "square.grid.3x3.fill")
                        Label(viewModel.pixelGridLabel, systemImage: "square.split.2x2")
                    }
                    
                    VStack(alignment: .leading) {
                        Label(viewModel.sourceDimensionsLabel, systemImage: "photo")
                        Label(viewModel.pixelSizeLabel, systemImage: "square.grid.3x3.fill")
                        Label(viewModel.pixelGridLabel, systemImage: "square.split.2x2")
                    }
                }
                .headline()
                .padding()
                .background(.regularMaterial, in: .rect(cornerRadius: 28))
            }
        }
    }
}
