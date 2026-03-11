import SwiftUI

@Observable
final class PixelArtViewModel {
    var selectedPixelSize = 18.0 {
        didSet {
            schedulePixelArtRefresh()
        }
    }
    
    var isImportingImage = false
    var isLoadingImage = false
    var isRenderingPixelArt = false
    var isDropTargeted = false
    var originalImage: CGImage?
    var pixelizedImage: CGImage?
    var exportURL: URL?
    var importError: PixelArtImportError?
    var sourceName = ""
    
    @ObservationIgnored
    private var refreshTask: Task<Void, Never>?
    
    var hasImage: Bool {
        originalImage != nil
    }
    
    var pixelSizeLabel: String {
        "\(Int(selectedPixelSize).formatted()) px"
    }
    
    var sourceDimensionsLabel: String {
        guard let originalImage else {
            return "No image selected"
        }
        
        return "\(originalImage.width.formatted()) × \(originalImage.height.formatted())"
    }
    
    var pixelGridLabel: String {
        guard let originalImage else {
            return "No pixel grid yet"
        }
        
        let pixelLength = max(1, Int(selectedPixelSize.rounded()))
        let columns = max(1, originalImage.width / pixelLength)
        let rows = max(1, originalImage.height / pixelLength)
        return "\(columns.formatted()) × \(rows.formatted()) blocks"
    }
    
    func clearImage() {
        refreshTask?.cancel()
        originalImage = nil
        pixelizedImage = nil
        exportURL = nil
        importError = nil
        sourceName = ""
        isLoadingImage = false
        isRenderingPixelArt = false
    }
    
    func handleImportResult(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            Task {
                await loadImage(from: url)
            }
        case .failure(let error):
            if (error as NSError).code == NSUserCancelledError {
                return
            }
            
            importError = PixelArtImportError(message: "That image couldn’t be opened")
        }
    }
    
    func handleDroppedItems(_ items: [URL]) -> Bool {
        guard let url = items.first else {
            return false
        }
        
        Task {
            await loadImage(from: url)
        }
        
        return true
    }
    
    private func loadImage(from url: URL) async {
        refreshTask?.cancel()
        importError = nil
        isLoadingImage = true
        isRenderingPixelArt = false
        
        do {
            let loadedImage = try await Task.detached(priority: .userInitiated) {
                try PixelArtRenderer.loadImage(from: url)
            }.value
            
            originalImage = loadedImage.image
            sourceName = loadedImage.name
            isLoadingImage = false
            
            await renderPixelArt(for: loadedImage.image)
        } catch {
            isLoadingImage = false
            importError = PixelArtImportError(message: "That image couldn’t be loaded as a bitmap")
        }
    }
    
    private func schedulePixelArtRefresh() {
        guard let originalImage else {
            return
        }
        
        refreshTask?.cancel()
        refreshTask = Task {
            isRenderingPixelArt = true
            
            try? await Task.sleep(for: .milliseconds(120))
            
            guard !Task.isCancelled else {
                return
            }
            
            await renderPixelArt(for: originalImage)
        }
    }
    
    private func renderPixelArt(for image: CGImage) async {
        isRenderingPixelArt = true
        
        let pixelLength = max(1, Int(selectedPixelSize.rounded()))
        let sourceName = sourceName
        
        do {
            let rendered = try await Task.detached(priority: .userInitiated) {
                guard let pixelizedImage = PixelArtRenderer.pixelize(image, pixelLength: pixelLength) else {
                    throw PixelArtRenderer.Failure.unableToCreateContext
                }
                
                let exportURL = try PixelArtRenderer.writePNG(
                    image: pixelizedImage,
                    sourceName: sourceName,
                    pixelLength: pixelLength
                )
                
                return (pixelizedImage, exportURL)
            }.value
            
            guard !Task.isCancelled else {
                return
            }
            
            pixelizedImage = rendered.0
            exportURL = rendered.1
            isRenderingPixelArt = false
        } catch {
            isRenderingPixelArt = false
            importError = PixelArtImportError(message: "Pixel art rendering failed for that image")
        }
    }
}
