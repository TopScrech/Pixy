import Foundation

struct PixelArtImportError: Error, Identifiable {
    let id = UUID()
    let message: String
}
