import SwiftUI

struct PixelArtDropZoneView: View {
    @Bindable var viewModel: PixelArtViewModel
    
    var body: some View {
        VStack {
            if viewModel.isLoadingImage {
                ProgressView("Importing image")
                    .progressViewStyle(.circular)
                    .frame(maxWidth: .infinity, minHeight: 240)
            } else {
                VStack {
                    Image(systemName: viewModel.hasImage ? "photo.stack" : "square.and.arrow.down")
                        .font(.largeTitle)
                        .foregroundStyle(viewModel.isDropTargeted ? .red : .primary)
                    
                    Text(viewModel.hasImage ? "Drop another image to replace the current one" : "Drop an image here")
                        .font(.title2)
                        .bold()
                    
                    Text(viewModel.hasImage ? viewModel.sourceName : "Or pick one from your files")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    ViewThatFits(in: .horizontal) {
                        HStack {
                            Button(
                                viewModel.hasImage ? "Replace Image" : "Choose Image",
                                systemImage: viewModel.hasImage ? "arrow.trianglehead.2.clockwise.rotate.90" : "folder"
                            ) {
                                viewModel.isImportingImage = true
                            }
                            .buttonStyle(.borderedProminent)
                            
                            if viewModel.hasImage {
                                Button("Clear", systemImage: "trash", action: viewModel.clearImage)
                                    .buttonStyle(.bordered)
                            }
                        }
                        
                        VStack {
                            Button(
                                viewModel.hasImage ? "Replace Image" : "Choose Image",
                                systemImage: viewModel.hasImage ? "arrow.trianglehead.2.clockwise.rotate.90" : "folder"
                            ) {
                                viewModel.isImportingImage = true
                            }
                            .buttonStyle(.borderedProminent)
                            
                            if viewModel.hasImage {
                                Button("Clear", systemImage: "trash", action: viewModel.clearImage)
                                    .buttonStyle(.bordered)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 240)
                .padding()
            }
        }
        .background(.thinMaterial, in: .rect(cornerRadius: 32))
        .overlay {
            RoundedRectangle(cornerRadius: 32)
                .strokeBorder(
                    style: StrokeStyle(lineWidth: 2, dash: [12, 12])
                )
                .foregroundStyle(viewModel.isDropTargeted ? .red : .primary.opacity(0.25))
        }
        .dropDestination(for: URL.self) { items, _ in
            viewModel.handleDroppedItems(items)
        } isTargeted: {
            viewModel.isDropTargeted = $0
        }
    }
}
