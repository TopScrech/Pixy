import Foundation

struct ImportError: Error, Identifiable {
    let id = UUID()
    let message: String
}
