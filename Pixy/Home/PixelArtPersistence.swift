import Foundation
import CoreGraphics

struct PixelArtPersistence {
    nonisolated private static var selectedPixelSizeKey: String {
        "pixelArt.selectedPixelSize"
    }
    
    nonisolated private static var usesTwoColorsKey: String {
        "pixelArt.usesTwoColors"
    }
    
    nonisolated private static var sourceNameKey: String {
        "pixelArt.sourceName"
    }
    
    nonisolated private static var sourceBookmarkKey: String {
        "pixelArt.sourceBookmark"
    }
    
    nonisolated private static var persistedImageFolderName: String {
        "Pixy"
    }
    
    nonisolated private static var persistedImageName: String {
        "last-imported-image.png"
    }
    
    nonisolated private static var bookmarkCreationOptions: URL.BookmarkCreationOptions {
        #if os(macOS)
        [.minimalBookmark, .withSecurityScope]
        #else
        .minimalBookmark
        #endif
    }
    
    nonisolated private static var bookmarkResolutionOptions: URL.BookmarkResolutionOptions {
        #if os(macOS)
        [.withoutUI, .withSecurityScope]
        #else
        .withoutUI
        #endif
    }
    
    nonisolated static func loadPixelSize(defaultValue: Double) -> Double {
        let savedValue = UserDefaults.standard.double(forKey: selectedPixelSizeKey)
        return savedValue == 0 ? defaultValue : savedValue
    }
    
    nonisolated static func savePixelSize(_ pixelSize: Double) {
        UserDefaults.standard.set(pixelSize, forKey: selectedPixelSizeKey)
    }
    
    nonisolated static func loadUsesTwoColors() -> Bool {
        UserDefaults.standard.bool(forKey: usesTwoColorsKey)
    }
    
    nonisolated static func saveUsesTwoColors(_ usesTwoColors: Bool) {
        UserDefaults.standard.set(usesTwoColors, forKey: usesTwoColorsKey)
    }
    
    nonisolated static func saveImportedImage(from sourceURL: URL, sourceName: String) throws {
        let isScoped = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if isScoped {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }
        
        let bookmark = try sourceURL.bookmarkData(
            options: bookmarkCreationOptions,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
        
        if Task.isCancelled {
            return
        }
        
        UserDefaults.standard.set(bookmark, forKey: sourceBookmarkKey)
        UserDefaults.standard.set(sourceName, forKey: sourceNameKey)
    }
    
    nonisolated static func loadImportedImage() throws -> (image: CGImage, sourceName: String)? {
        if let restoredImage = try loadBookmarkedImage() {
            return restoredImage
        }
        
        let imageURL = try persistedImageURL()
        try migratePersistedImageIfNeeded(to: imageURL)
        
        guard FileManager.default.fileExists(atPath: imageURL.path()) else {
            return nil
        }
        
        let loadedImage = try Renderer.loadImage(from: imageURL)
        let sourceName = UserDefaults.standard.string(forKey: sourceNameKey) ?? loadedImage.name
        
        return (loadedImage.image, sourceName)
    }
    
    nonisolated static func removeImportedImage() {
        let imageURL = try? persistedImageURL()
        let legacyImageURL = legacyPersistedImageURL()
        
        if let imageURL {
            try? FileManager.default.removeItem(at: imageURL)
        }
        
        if let legacyImageURL {
            try? FileManager.default.removeItem(at: legacyImageURL)
        }
        
        UserDefaults.standard.removeObject(forKey: sourceNameKey)
        UserDefaults.standard.removeObject(forKey: sourceBookmarkKey)
    }
    
    nonisolated private static func loadBookmarkedImage() throws -> (image: CGImage, sourceName: String)? {
        guard let bookmark = UserDefaults.standard.data(forKey: sourceBookmarkKey) else {
            return nil
        }
        
        var isStale = false
        let url = try URL(
            resolvingBookmarkData: bookmark,
            options: bookmarkResolutionOptions,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )
        
        if isStale {
            UserDefaults.standard.removeObject(forKey: sourceBookmarkKey)
            return nil
        }
        
        let loadedImage = try Renderer.loadImage(from: url)
        let sourceName = UserDefaults.standard.string(forKey: sourceNameKey) ?? loadedImage.name
        
        return (loadedImage.image, sourceName)
    }
    
    nonisolated private static func persistedImageURL() throws -> URL {
        let directory = URL.documentsDirectory
            .appending(path: persistedImageFolderName, directoryHint: .isDirectory)
        
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        
        return directory.appending(path: persistedImageName)
    }
    
    nonisolated private static func legacyPersistedImageURL() -> URL? {
        URL.applicationSupportDirectory
            .appending(path: "Image to Pixel Art", directoryHint: .isDirectory)
            .appending(path: persistedImageName)
    }
    
    nonisolated private static func migratePersistedImageIfNeeded(to imageURL: URL) throws {
        guard !FileManager.default.fileExists(atPath: imageURL.path()),
              let legacyImageURL = legacyPersistedImageURL(),
              FileManager.default.fileExists(atPath: legacyImageURL.path()) else {
            return
        }
        
        try FileManager.default.copyItem(at: legacyImageURL, to: imageURL)
    }
}
