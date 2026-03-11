import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

struct PixelArtRenderer {
    enum Failure: LocalizedError {
        case unreadableImage, unableToCreateContext, unableToExportImage
        
        var errorDescription: String? {
            switch self {
            case .unreadableImage: "The image data couldn’t be decoded"
            case .unableToCreateContext: "The pixel art preview couldn’t be rendered"
            case .unableToExportImage: "The PNG export couldn’t be written"
            }
        }
    }
    
    nonisolated static func loadImage(from url: URL) throws -> (image: CGImage, name: String) {
        let isScoped = url.startAccessingSecurityScopedResource()
        defer {
            if isScoped {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            throw Failure.unreadableImage
        }
        
        let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        let pixelWidth = properties?[kCGImagePropertyPixelWidth] as? Int ?? 1
        let pixelHeight = properties?[kCGImagePropertyPixelHeight] as? Int ?? 1
        let maxPixelSize = max(pixelWidth, pixelHeight, 1)
        
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
            kCGImageSourceShouldCacheImmediately: true
        ]
        
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            throw Failure.unreadableImage
        }
        
        return (image, url.deletingPathExtension().lastPathComponent)
    }
    
    nonisolated static func pixelize(_ image: CGImage, pixelLength: Int) -> CGImage? {
        let pixelWidth = max(1, image.width / max(1, pixelLength))
        let pixelHeight = max(1, image.height / max(1, pixelLength))
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        
        guard let reducedContext = CGContext(
            data: nil,
            width: pixelWidth,
            height: pixelHeight,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }
        
        reducedContext.interpolationQuality = .none
        reducedContext.draw(image, in: CGRect(x: 0, y: 0, width: pixelWidth, height: pixelHeight))
        
        guard let reducedImage = reducedContext.makeImage() else {
            return nil
        }
        
        guard let outputContext = CGContext(
            data: nil,
            width: image.width,
            height: image.height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }
        
        outputContext.interpolationQuality = .none
        outputContext.draw(reducedImage, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        return outputContext.makeImage()
    }
    
    nonisolated static func writePNG(image: CGImage, sourceName: String, pixelLength: Int) throws -> URL {
        let fileName = sanitizedFileName(for: sourceName, pixelLength: pixelLength)
        let url = URL.cachesDirectory.appending(path: fileName)
        try writePNG(image: image, to: url)
        return url
    }
    
    nonisolated static func writePNG(image: CGImage, to url: URL) throws {
        let parentDirectory = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: parentDirectory, withIntermediateDirectories: true)
        
        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.png.identifier as CFString,
            1,
            nil
        ) else {
            throw Failure.unableToExportImage
        }
        
        CGImageDestinationAddImage(destination, image, nil)
        
        guard CGImageDestinationFinalize(destination) else {
            throw Failure.unableToExportImage
        }
    }
    
    nonisolated private static func sanitizedFileName(for sourceName: String, pixelLength: Int) -> String {
        let cleanedName = sourceName
            .replacing(/[^\p{Letter}\p{Number}]+/, with: "-")
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        
        let fallbackName = cleanedName.isEmpty ? "pixel-art" : cleanedName
        return "\(fallbackName)-\(pixelLength.formatted())px.png"
    }
}
