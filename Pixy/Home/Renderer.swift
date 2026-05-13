import ImageIO
import UniformTypeIdentifiers

struct Renderer {
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
    
    nonisolated static func loadImage(from data: Data, name: String) throws -> (image: CGImage, name: String) {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
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
        
        return (image, name)
    }
    
    nonisolated static func pixelize(_ image: CGImage, pixelLength: Int, colorMode: PixelColorMode) -> CGImage? {
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
        
        let outputImage: CGImage
        
        switch colorMode {
        case .color:
            outputImage = reducedImage
            
        case .grayscale, .blackAndWhite:
            guard let mappedImage = colorMappedImage(from: reducedImage, colorMode: colorMode) else {
                return nil
            }
            
            outputImage = mappedImage
        }
        
        return outputImage
    }
    
    nonisolated static func writePNG(image: CGImage, sourceName: String, pixelLength: Int, colorMode: PixelColorMode) throws -> URL {
        let fileName = sanitizedFileName(
            for: sourceName,
            pixelLength: pixelLength,
            colorMode: colorMode
        )
        
        let url = URL.cachesDirectory.appending(path: fileName)
        try writePNG(image: image, to: url)
        
        return url
    }
    
    nonisolated static func writePNG(image: CGImage, to url: URL) throws {
        let parentDirectory = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: parentDirectory, withIntermediateDirectories: true)
        
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
            throw Failure.unableToExportImage
        }
        
        CGImageDestinationAddImage(destination, image, nil)
        
        guard CGImageDestinationFinalize(destination) else {
            throw Failure.unableToExportImage
        }
    }
    
    nonisolated private static func colorMappedImage(from image: CGImage, colorMode: PixelColorMode) -> CGImage? {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        
        guard let context = CGContext(
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
        
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        
        guard let data = context.data else {
            return nil
        }
        
        let byteCount = context.bytesPerRow * image.height
        let pixels = data.bindMemory(to: UInt8.self, capacity: byteCount)
        
        for pixelOffset in stride(from: 0, to: byteCount, by: 4) {
            let alpha = pixels[pixelOffset + 3]
            
            if alpha == 0 {
                pixels[pixelOffset] = 0
                pixels[pixelOffset + 1] = 0
                pixels[pixelOffset + 2] = 0
                continue
            }
            
            let red = Double(pixels[pixelOffset])
            let green = Double(pixels[pixelOffset + 1])
            let blue = Double(pixels[pixelOffset + 2])
            let luminance = (0.2126 * red) + (0.7152 * green) + (0.0722 * blue)
            let colorValue = switch colorMode {
            case .color, .grayscale: UInt8(luminance.rounded())
            case .blackAndWhite: luminance >= 128 ? UInt8(255) : UInt8(0)
            }
            
            pixels[pixelOffset] = colorValue
            pixels[pixelOffset + 1] = colorValue
            pixels[pixelOffset + 2] = colorValue
        }
        
        return context.makeImage()
    }
    
    nonisolated private static func sanitizedFileName(for sourceName: String, pixelLength: Int, colorMode: PixelColorMode) -> String {
        let cleanedName = sourceName
            .replacing(/[^\p{Letter}\p{Number}]+/, with: "-")
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        
        let fallbackName = cleanedName.isEmpty ? "pixel-art" : cleanedName
        
        return "\(fallbackName)-\(pixelLength.formatted())px\(colorMode.fileNameSuffix).png"
    }
}
