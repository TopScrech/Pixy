import CoreGraphics
import Foundation

private let pixelArtSelectedPixelSizeKey = "pixelArt.selectedPixelSize"
private let pixelArtUsesTwoColorsKey = "pixelArt.usesTwoColors"
private let pixelArtSourceNameKey = "pixelArt.sourceName"
private let pixelArtPersistedImageName = "last-imported-image.png"

struct PixelArtPersistence {
    static func loadPixelSize(defaultValue: Double) -> Double {
        let savedValue = UserDefaults.standard.double(forKey: pixelArtSelectedPixelSizeKey)
        return savedValue == 0 ? defaultValue : savedValue
    }
    
    static func savePixelSize(_ pixelSize: Double) {
        UserDefaults.standard.set(pixelSize, forKey: pixelArtSelectedPixelSizeKey)
    }
    
    static func loadUsesTwoColors() -> Bool {
        UserDefaults.standard.bool(forKey: pixelArtUsesTwoColorsKey)
    }
    
    static func saveUsesTwoColors(_ usesTwoColors: Bool) {
        UserDefaults.standard.set(usesTwoColors, forKey: pixelArtUsesTwoColorsKey)
    }
    
    static func saveImportedImage(_ image: CGImage, sourceName: String) throws {
        let imageURL = try persistedImageURL()
        try PixelArtRenderer.writePNG(image: image, to: imageURL)
        
        UserDefaults.standard.set(sourceName, forKey: pixelArtSourceNameKey)
    }
    
    static func loadImportedImage() throws -> (image: CGImage, sourceName: String)? {
        let imageURL = try persistedImageURL()
        
        guard FileManager.default.fileExists(atPath: imageURL.path()) else {
            return nil
        }
        
        let loadedImage = try PixelArtRenderer.loadImage(from: imageURL)
        let sourceName = UserDefaults.standard.string(forKey: pixelArtSourceNameKey) ?? loadedImage.name
        
        return (loadedImage.image, sourceName)
    }
    
    static func removeImportedImage() {
        let imageURL = try? persistedImageURL()
        
        if let imageURL {
            try? FileManager.default.removeItem(at: imageURL)
        }
        
        UserDefaults.standard.removeObject(forKey: pixelArtSourceNameKey)
    }
    
    private static func persistedImageURL() throws -> URL {
        let directory = URL.applicationSupportDirectory
            .appending(path: "Image to Pixel Art", directoryHint: .isDirectory)
        
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appending(path: pixelArtPersistedImageName)
    }
}
