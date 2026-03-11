import SwiftUI

struct PixelArtPreviewCardView: View {
    let title: String
    let subtitle: String
    let image: CGImage?
    let isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title3)
                .bold()
            
            Text(subtitle)
                .font(.headline)
                .foregroundStyle(.secondary)
            
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(.white.opacity(0.78))
                
                if let image {
                    Image(decorative: image, scale: 1)
                        .interpolation(.none)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                } else if isLoading {
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
