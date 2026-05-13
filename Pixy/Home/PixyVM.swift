import SwiftUI

@Observable
final class PixyVM {
    var selectedPixelSize = 18.0 {
        didSet {
            PixelArtPersistence.savePixelSize(selectedPixelSize)
            schedulePixelArtRefresh()
        }
    }
    
    var usesTwoColors = false {
        didSet {
            PixelArtPersistence.saveUsesTwoColors(usesTwoColors)
            schedulePixelArtRefresh()
        }
    }
    
    var isImportingImage = false
    var isPickingPhoto = false
    var isTakingPhoto = false
    var isLoadingImage = false
    var isRenderingPixelArt = false
    var isDropTargeted = false
    var originalImage: CGImage?
    var pixelizedImage: CGImage?
    var exportURL: URL?
    var importError: ImportError?
    var sourceName = ""
    
    @ObservationIgnored
    private var refreshTask: Task<Void, Never>?
    
    @ObservationIgnored
    private var persistenceTask: Task<Void, Never>?
    
    @ObservationIgnored
    private var renderRevision = 0
    
    @ObservationIgnored
    private var hasRestoredPersistedImage = false
    
    @ObservationIgnored
    private var isRestoringPersistedImage = false
    
    init() {
        selectedPixelSize = PixelArtPersistence.loadPixelSize(defaultValue: 18)
        usesTwoColors = PixelArtPersistence.loadUsesTwoColors()
    }
    
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
    
    var sourceAspectRatio: CGFloat? {
        guard let originalImage else {
            return nil
        }
        
        return CGFloat(originalImage.width) / CGFloat(originalImage.height)
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
        persistenceTask?.cancel()
        renderRevision += 1
        originalImage = nil
        pixelizedImage = nil
        exportURL = nil
        importError = nil
        sourceName = ""
        isLoadingImage = false
        isRenderingPixelArt = false
        PixelArtPersistence.removeImportedImage()
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
            
            importError = ImportError(message: "That image couldn’t be opened")
        }
    }
    
    func handlePhotoPickerData(_ data: Data?) {
        guard let data else {
            importError = ImportError(message: "That photo couldn’t be opened")
            return
        }
        
        Task {
            await loadImage(from: data, sourceName: "Photo Library")
        }
    }
    
    func handleCameraData(_ data: Data?) {
        guard let data else {
            return
        }
        
        Task {
            await loadImage(from: data, sourceName: "Camera")
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
        renderRevision += 1
        importError = nil
        isLoadingImage = true
        isRenderingPixelArt = false
        
        do {
            let loadedImage = try await Task.detached(priority: .userInitiated) {
                try Renderer.loadImage(from: url)
            }.value
            
            originalImage = loadedImage.image
            sourceName = loadedImage.name
            isLoadingImage = false
            persistImportedImage(
                image: loadedImage.image,
                sourceURL: url,
                sourceName: loadedImage.name
            )
            
            schedulePixelArtRefresh()
        } catch {
            isLoadingImage = false
            importError = ImportError(message: "That image couldn’t be loaded as a bitmap")
        }
    }
    
    private func loadImage(from data: Data, sourceName: String) async {
        refreshTask?.cancel()
        renderRevision += 1
        importError = nil
        isLoadingImage = true
        isRenderingPixelArt = false
        
        do {
            let loadedImage = try await Task.detached(priority: .userInitiated) {
                try Renderer.loadImage(from: data, name: sourceName)
            }.value
            
            originalImage = loadedImage.image
            self.sourceName = loadedImage.name
            isLoadingImage = false
            persistImportedImage(
                image: loadedImage.image,
                sourceURL: nil,
                sourceName: loadedImage.name
            )
            
            schedulePixelArtRefresh()
        } catch {
            isLoadingImage = false
            importError = ImportError(message: "That image couldn’t be loaded as a bitmap")
        }
    }
    
    private func schedulePixelArtRefresh() {
        guard let originalImage else {
            return
        }
        
        refreshTask?.cancel()
        renderRevision += 1
        let revision = renderRevision
        
        refreshTask = Task {
            isRenderingPixelArt = true
            await renderPixelArt(for: originalImage, revision: revision)
        }
    }
    
    private func renderPixelArt(for image: CGImage, revision: Int) async {
        let pixelLength = max(1, Int(selectedPixelSize.rounded()))
        let sourceName = sourceName
        let usesTwoColors = usesTwoColors
        
        do {
            let rendered = try await Task.detached(priority: .userInitiated) {
                guard let pixelizedImage = Renderer.pixelize(
                    image,
                    pixelLength: pixelLength,
                    usesTwoColors: usesTwoColors
                ) else {
                    throw Renderer.Failure.unableToCreateContext
                }
                
                let exportURL = try Renderer.writePNG(
                    image: pixelizedImage,
                    sourceName: sourceName,
                    pixelLength: pixelLength,
                    usesTwoColors: usesTwoColors
                )
                
                return (pixelizedImage, exportURL)
            }.value
            
            guard !Task.isCancelled, revision == renderRevision else {
                return
            }
            
            pixelizedImage = rendered.0
            exportURL = rendered.1
            isRenderingPixelArt = false
        } catch {
            guard !Task.isCancelled, revision == renderRevision else {
                return
            }
            
            isRenderingPixelArt = false
            importError = ImportError(message: "Pixel art rendering failed for that image")
        }
    }
    
    func restorePersistedImageIfNeeded() async {
        guard !hasRestoredPersistedImage, !isRestoringPersistedImage else {
            return
        }
        
        isRestoringPersistedImage = true
        defer {
            hasRestoredPersistedImage = true
            isRestoringPersistedImage = false
        }
        
        do {
            let restoredImage = try await Task.detached(priority: .userInitiated) {
                try PixelArtPersistence.loadImportedImage()
            }.value
            
            guard let restoredImage else {
                return
            }
            
            originalImage = restoredImage.image
            sourceName = restoredImage.sourceName
            schedulePixelArtRefresh()
        } catch {
            PixelArtPersistence.removeImportedImage()
        }
    }
    
    private func persistImportedImage(image: CGImage, sourceURL: URL?, sourceName: String) {
        persistenceTask?.cancel()
        persistenceTask = Task.detached(priority: .utility) {
            try? PixelArtPersistence.saveImportedImage(
                image: image,
                sourceURL: sourceURL,
                sourceName: sourceName
            )
        }
    }
}
