import SwiftUI
import ScrechKit

struct PixelArtDropZoneView: View {
    @Bindable var vm: PixelArtVM
    
    var body: some View {
        VStack {
            if vm.isLoadingImage {
                ProgressView("Importing image")
                    .progressViewStyle(.circular)
                    .frame(maxWidth: .infinity, minHeight: 240)
            } else {
                VStack {
                    Image(systemName: vm.hasImage ? "photo.stack" : "square.and.arrow.down")
                        .largeTitle()
                        .foregroundStyle(vm.isDropTargeted ? .red : .primary)
                    
                    Text(vm.hasImage ? "Drop another image to replace the current one" : "Drop an image here")
                        .title2(.bold)
                    
                    Text(vm.hasImage ? vm.sourceName : "Or pick one from your files")
                        .headline()
                        .secondary()
                    
                    ViewThatFits(in: .horizontal) {
                        HStack {
                            Button(
                                vm.hasImage ? "Replace Image" : "Choose Image",
                                systemImage: vm.hasImage ? "arrow.trianglehead.2.clockwise.rotate.90" : "folder"
                            ) {
                                vm.isImportingImage = true
                            }
                            .buttonStyle(.borderedProminent)
                            
                            if vm.hasImage {
                                Button("Clear", systemImage: "trash", action: vm.clearImage)
                                    .buttonStyle(.bordered)
                            }
                        }
                        
                        VStack {
                            Button(
                                vm.hasImage ? "Replace Image" : "Choose Image",
                                systemImage: vm.hasImage ? "arrow.trianglehead.2.clockwise.rotate.90" : "folder"
                            ) {
                                vm.isImportingImage = true
                            }
                            .buttonStyle(.borderedProminent)
                            
                            if vm.hasImage {
                                Button("Clear", systemImage: "trash", action: vm.clearImage)
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
                .foregroundStyle(vm.isDropTargeted ? .red : .primary.opacity(0.25))
        }
        .dropDestination(for: URL.self) { items, _ in
            vm.handleDroppedItems(items)
        } isTargeted: {
            vm.isDropTargeted = $0
        }
    }
}
